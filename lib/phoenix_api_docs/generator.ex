defmodule PhoenixApiDocs.Generator do

  def run do
    test_conns = PhoenixApiDocs.ConnLogger.conns
    app_module = Mix.Project.get.application |> Keyword.get(:mod) |> elem(0)
    router_module = Module.concat([app_module, :Router])

    %{
      host: Keyword.get(api_docs_info, :host, "http://localhost"),
      title: Keyword.get(api_docs_info, :title, "API Documentation"),
      description: Keyword.get(api_docs_info, :description, "Enter API description in mix.exs - api_docs_info"),
      routes: routes_docs(router_module, test_conns)
    }
  end

  defp api_docs_info do
    case function_exported?(Mix.Project.get, :api_docs_info, 0) do
      true ->
        Mix.Project.get.api_docs_info
      false ->
        []
    end
  end

  defp routes_docs(router_module, test_conns) do
    requests_list = requests(router_module.__routes__, test_conns)

    router_module.__routes__
    |> Enum.filter(fn(route) -> Enum.member?(route.pipe_through, :api) end)
    |> Enum.reduce([], fn(route, routes_docs) ->
      case process_route(route, requests_list) do
        {:ok, route_doc} ->
          routes_docs ++ [route_doc]
        _ ->
          routes_docs
      end
    end)
  end

  defp requests(routes, test_conns) do
    Enum.reduce test_conns, [], fn(conn, list) ->
      case find_route(routes, conn.request_path) do
        nil ->
          list
        route ->
          list ++ [request_map(route, conn)]
      end
    end
  end

  defp request_map(route, conn) do
    request = %{
      method: conn.method,
      path: route.path,
      response: %{
        status: conn.status,
        body: conn.resp_body
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
    |> Enum.find(fn(route) ->
      route_match?(route.path, path)
    end)
  end

  defp route_match?(route, path) do
    route_regex = Regex.replace(~r/(:[^\/]+)/, route, "([^/]+)") |> Regex.compile!
    Regex.match?(route_regex, path)
  end

  defp process_route(route, requests) do
    controller = Module.concat([:Elixir | Module.split(route.plug)])
    method = route.verb |> Atom.to_string |> String.upcase
    route_requests = Enum.filter(requests, fn(request) -> request.method == method and request.path == route.path end)
    try do
      route_docs =
        apply(controller, :api_doc, [method, route.path])
        |> Map.put(:requests, route_requests)

      {:ok, route_docs}
    rescue
      UndefinedFunctionError ->
        :error
      FunctionClauseError ->
        :error
    end
  end

end
