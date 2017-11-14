defmodule BlueBird.Generator do
  @moduledoc """
  Generates a map containing information about the api routes.

  `BlueBird.Generator` uses the connections logged by `BlueBird.ConnLogger` and
  the functions generated by the `BlueBird.Controller.api/3` macro to generate
  a map containing all the data that is needed to generate the doc file.

  It is called when `BlueBird.Formatter` receives the `:suite_finished` event
  by `ExUnit` and immediately piped to `BlueBird.BlueprintWriter` to write
  the documentation to file.
  """
  require Logger

  alias BlueBird.{ApiDoc, ConnLogger, Request, Response, Route}
  alias Mix.Project
  alias Phoenix.Naming
  alias Phoenix.Router.Route, as: PhxRoute

  @default_url "http://localhost"
  @default_title "API Documentation"
  @default_description "Enter API description in mix.exs - blue_bird_info"

  @doc """
  Generates a map from logged connections and the `api/3` macros.

  ## Example response

      %BlueBird.ApiDoc{
        description: "Enter API description in mix.exs - blue_bird_info",
        host: "http://localhost",
        routes: [
          %BlueBird.Route{
            description: "Gets a single user.",
            group: "Users",
            method: "GET",
            note: nil,
            parameters: [
              %BlueBird.Parameter{
                description: "ID",
                name: "id",
                type: "int"
              }
            ],
            path: "/users/:id",
            title: "Get single user",
            warning: nil,
            requests: [
              %BlueBird.Request{
                body_params: %{},
                headers: [{"accept", "application/json"}],
                method: "GET",
                path: "/user/:id",
                path_params: %{"id" => 1},
                query_params: %{},
                response: %BlueBird.Response{
                  body: "{\\"status\\":\\"ok\\"}",
                  headers: [{"content-type", "application/json"}],
                  status: 200
                }
              }
            ]
          }
        ]
      }
  """
  @spec run :: ApiDoc.t
  def run do
    get_app_module()
    |> get_router_module()
    |> prepare_docs()
  end

  @doc false
  @spec get_app_module :: atom
  def get_app_module do
    Project.get.application
    |> Keyword.get(:mod)
    |> elem(0)
  end

  @doc false
  @spec get_router_module(atom) :: atom
  def get_router_module(app_module) do
    Application.get_env(
      :blue_bird,
      :router,
      Module.concat([app_module, :Router])
    )
  end

  @spec prepare_docs(atom) :: ApiDoc.t
  defp prepare_docs(router_module) do
    info = blue_bird_info()

    %ApiDoc{
      host: Keyword.get(info, :host, @default_url),
      title: Keyword.get(info, :title, @default_title),
      description: Keyword.get(info, :description, @default_description),
      routes: generate_docs_for_routes(router_module)
    }
  end

  @spec blue_bird_info :: [String.t]
  defp blue_bird_info do
    case function_exported?(Project.get, :blue_bird_info, 0) do
      true  -> Project.get.blue_bird_info()
      false -> []
    end
  end

  @spec generate_docs_for_routes(atom) :: [Request.t]
  defp generate_docs_for_routes(router_module) do
    routes = filter_api_routes(router_module.__routes__)

    ConnLogger.get_conns()
    |> requests(routes)
    |> process_routes(routes)
  end

  @spec filter_api_routes([%PhxRoute{}]) :: [%PhxRoute{}]
  defp filter_api_routes(routes) do
    pipelines = Application.get_env(
      :blue_bird,
      :pipelines,
      [:api]
    )

    Enum.filter(
      routes,
      fn route ->
        Enum.any?(
          pipelines,
          &Enum.member?(route.pipe_through, &1)
        )
      end
    )
  end

  @spec requests([Plug.Conn.t], [%PhxRoute{}]) :: [Plug.Conn.t]
  defp requests(test_conns, routes) do
    Enum.reduce(test_conns, [], fn(conn, list) ->
      case find_route(routes, conn.request_path) do
        nil   -> list
        route -> [request_map(route, conn) | list]
      end
    end)
  end

  @spec find_route([%PhxRoute{}], String.t) :: %PhxRoute{} | nil
  defp find_route(routes, path) do
    routes
    |> Enum.sort_by(fn(route) -> -byte_size(route.path) end)
    |> Enum.find(fn(route) -> route_match?(route.path, path) end)
  end

  @spec route_match?(String.t, String.t) :: boolean
  defp route_match?(route, path) do
    ~r/(:[^\/]+)/
    |> Regex.replace(route, "([^/]+)")
    |> Regex.compile!()
    |> Regex.match?(path)
  end

  @spec request_map(%PhxRoute{}, %Plug.Conn{}) :: Request.t
  defp request_map(route, conn) do
    %Request{
      method: conn.method,
      path: route.path,
      headers: conn.req_headers,
      path_params: conn.path_params,
      body_params: conn.body_params,
      query_params: conn.query_params,
      response: %Response{
        status: conn.status,
        body: conn.resp_body,
        headers: conn.resp_headers
      }
    }
  end

  @spec process_routes([Request.t], [%PhxRoute{}]) :: [Request.t]
  defp process_routes(requests_list, routes) do
    routes
    |> Enum.reduce([], fn(route, generate_docs_for_routes) ->
         case process_route(route, requests_list) do
           {:ok, route_doc} -> [route_doc | generate_docs_for_routes]
           _                -> generate_docs_for_routes
         end
       end)
    |> Enum.reverse()
  end

  @spec process_route(%PhxRoute{}, [Request.t]) :: {:ok, Route.t} | :error
  defp process_route(route, requests) do
    controller = Module.concat([:Elixir | Module.split(route.plug)])
    method     = route.verb |> Atom.to_string |> String.upcase

    route_requests = Enum.filter(requests, fn(request) ->
      request.method == method and request.path == route.path
    end)

    try do
      route_docs = controller
      |> apply(:api_doc, [method, route.path])
      |> set_group(controller, route)
      |> Map.put(:requests, route_requests)

      {:ok, route_docs}
    rescue
      UndefinedFunctionError ->
        warning_message()
      FunctionClauseError ->
        warning_message()
    end
  end

  @spec set_group(Route.t, module, PhxRoute.t) :: Route.t
  defp set_group(route_docs, controller, route) do
    group_name = get_group_name(controller, route)
    Map.put(route_docs, :group, group_name)
  end

  @spec get_group_name(module, PhxRoute.t) :: String.t
  defp get_group_name(controller, route) do
    apply(controller, :api_group, []).name
  rescue
    UndefinedFunctionError ->
      route.plug
      |> Naming.resource_name("Controller")
      |> Naming.humanize
  end

  defp warning_message do
    if Application.get_env(:blue_bird, :definition_warning, true) do
      Logger.warn fn -> "No api doc defined for #{method} #{route.path}." end
    end
    :error
  end
end
