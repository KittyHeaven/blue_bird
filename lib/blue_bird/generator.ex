defmodule BlueBird.Generator do

  def run do
    get_app_module()
    |> get_router_module()
    |> generate_blueprint_file(BlueBird.ConnLogger.conns())
  end

  defp get_app_module do
    Mix.Project.get.application
    |> Keyword.get(:mod)
    |> elem(0)
  end

  defp get_router_module(app_module) do
    Application.get_env(:blue_bird, :router, Module.concat([app_module, :Router]))
  end

  def generate_blueprint_file(router_module, test_conns) do
    %{
      host: Keyword.get(blue_bird_info(), :host, "http://localhost"),
      title: Keyword.get(blue_bird_info(), :title, "API Documentation"),
      description: Keyword.get(blue_bird_info(), :description, "Enter API description in mix.exs - blue_bird_info"),
      routes: generate_docs_for_routes(router_module, test_conns)
    }
  end

  defp blue_bird_info do
    case function_exported?(Mix.Project.get, :blue_bird_info, 0) do
      true ->
        Mix.Project.get.blue_bird_info
      false ->
        []
    end
  end

  def generate_docs_for_routes(router_module, test_conns) do
    requests_list = requests(router_module.__routes__, test_conns)

    IO.puts "-------------------"
    IO.puts "-------------------"
    IO.puts "#{inspect test_conns}"
    IO.puts "-------------------"
    IO.puts "-------------------"
    IO.puts "#{inspect requests_list}"
    IO.puts "-------------------"
    IO.puts "-------------------"

    b = router_module.__routes__
    |> Enum.filter(fn(route) -> Enum.member?(route.pipe_through, :api) end)
    |> Enum.reduce([], fn(route, generate_docs_for_routes) ->
      case process_route(route, requests_list) do
        {:ok, route_doc} ->
          generate_docs_for_routes ++ [route_doc]
        _ ->
          generate_docs_for_routes
      end
    end)

    IO.puts "#{inspect b}"
    IO.puts "-------------------"
    IO.puts "-------------------"
    b
  end

  defp requests(routes, test_conns) do
    Enum.reduce test_conns, [], fn(conn, list) ->
      case find_route(routes, conn.request_path) do
        nil   -> list
        route -> list ++ [request_map(route, conn)]
      end
    end
  end

  defp request_map(route, conn) do
    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    IO.puts "#{inspect conn.body_params}"
    IO.puts "#{inspect route.path}"
    IO.puts "#{inspect conn.method}"
    IO.puts "#{inspect conn.req_headers}"
    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    request = %{
      method: conn.method,
      path: route.path,
      headers: conn.req_headers,
      path_params: conn.path_params,
      params: conn.params,
      body: Poison.encode!(conn.body_params), # TODO: Do we need this???
      response: %{
        status: conn.status,
        body: conn.resp_body,
        headers: conn.resp_headers
      }
    }
    if conn.body_params == %{} do
      request
    else
      request
      |> Map.put(:body, Poison.encode!(conn.body_params))
    end
  end

  defp find_route(routes, path) do
    routes
    |> Enum.sort_by(fn(route) -> -byte_size(route.path) end)
    |> Enum.find(fn(route) -> route_match?(route.path, path) end)
  end

  defp route_match?(route, path) do
    ~r/(:[^\/]+)/
    |> Regex.replace(route, "([^/]+)")
    |> Regex.compile!
    |> Regex.match?(path)
  end

  defp process_route(route, requests) do
    controller = Module.concat([:Elixir | Module.split(route.plug)])
    method = route.verb |> Atom.to_string |> String.upcase
    route_requests = Enum.filter(requests, fn(request) -> request.method == method and request.path == route.path end)
    try do
      route_docs =
        apply(controller, :api_doc, [method, route.path])
        |> set_default_group(route)
        |> Map.put(:requests, route_requests)

      {:ok, route_docs}
    rescue
      UndefinedFunctionError ->
        :error
      FunctionClauseError ->
        :error
    end
  end

  defp set_default_group(%{group: group} = route_docs, route) when is_nil(group) do
    group = route.plug |> Phoenix.Naming.resource_name("Controller") |> Phoenix.Naming.humanize

    route_docs
    |> Map.put(:group, group)
  end

  defp set_default_group(route_docs, _), do: route_docs

end
