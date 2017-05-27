defmodule BlueBird.Writer.Blueprint do
  @moduledoc """
  Defines functions to generate an API BluePrint representation of the
  `BlueBird.ApiDoc` struct.
  """
  alias BlueBird.{ApiDoc, Parameter, Request, Route}
  alias Mix.Project

  @docs_path Application.get_env(:blue_bird, :docs_path, "docs")

  @doc """
  Writes a `BlueBird.ApiDoc{}` struct to file.

  This function will be called automatically by `BlueBird.Formatter` after
  every test run.

  You can set the destination directory in `config.exs`.

      config :blue_bird,
        docs_path: "priv/static/docs"
  """
  @spec run(ApiDoc.t) :: :ok | {:error, File.posix}
  def run(api_docs) do
    api_docs
    |> generate_output()
    |> write_file()
  end

  @spec write_file(String.t) :: :ok | {:error, File.posix}
  defp write_file(output) do
    path = get_path()

    File.mkdir_p(path)

    path
    |> Path.join("api.apib")
    |> File.write(output)
  end

  @spec get_path :: binary
  defp get_path do
    Project.load_paths
    |> Enum.at(0)
    |> String.split("_build")
    |> Enum.at(0)
    |> Path.join(@docs_path)
  end

  @doc """
  Generates a string from an `BlueBird.ApiDocs{}` struct.
  """
  @spec generate_output(ApiDoc.t) :: String.t
  def generate_output(api_docs) do
    doc_routes = api_docs.routes
    |> group_routes(:group)
    |> process_groups

    print_metadata(api_docs.host) <> "\n"
    <> print_overview(api_docs.title, api_docs.description) <> "\n\n"
    <> doc_routes
  end

  ## Grouping

  @doc false
  @spec group_routes([Route.t], atom) :: [{String.t, [Route.t]}]
  def group_routes(routes, key) do
    routes
    |> Enum.group_by(fn(route) -> Map.get(route, key) end)
    |> Enum.to_list()
  end

  ## Groups

  @spec process_groups([{String.t, [{String.t, String.t, [Route.t]}]}]) ::
    String.t
  defp process_groups(groups) do
    Enum.map_join(groups, "\n", &process_group(&1))
  end

  @spec process_group({String.t | nil, [Route.t]}) :: String.t
  defp process_group({nil, routes}), do: process_routes(routes)
  defp process_group({group_name, routes}) do
    "# Group #{group_name}\n\n"
    <> process_routes(routes)
  end

  ## Routes

  @doc false
  @spec process_routes([Route.t]) :: String.t
  def process_routes(routes) do
    routes
    |> Enum.sort_by(&({&1.path, &1.method}))
    |> Enum.map_join("\n", fn(route) ->
      process_route(route)
    end)
  end

  @doc false
  @spec process_route(Route.t) :: String.t
  def process_route(route) do
    [
      print_route_definition(route),
      print_note(route.note),
      print_warning(route.warning),
      route.parameters |> process_parameters() |> indent(4),
      route.requests |> process_requests()
    ] |> Enum.reject(&(&1 == "")) |> Enum.join("\n")
  end

  ## Parameters

  @spec process_parameters([Parameter.t]) :: String.t
  defp process_parameters([_|_] = parameters) do
    "+ Parameters\n\n" <> parameter_list(parameters)
  end
  defp process_parameters(_), do: ""

  @spec parameter_list([Parameter.t]) :: String.t
  defp parameter_list(parameters) do
    parameters
    |> Enum.map_join("\n", &process_parameter(&1))
    |> indent(4)
  end

  @spec process_parameter(Parameter.t) :: String.t
  defp process_parameter(param) do
    "+ #{param.name}: (#{param.type}, required) "
    <> "- #{param.description}\n"
  end

  ## Requests

  @spec process_requests([Request.t]) :: String.t
  defp process_requests([_|_] = requests) do
    requests
    |> Enum.sort_by(&(&1.response.status))
    |> Enum.map_join("\n", &process_request(&1))
    #|> indent(4)
  end
  defp process_requests(_), do: ""

  @spec process_request(Request.t) :: String.t
  defp process_request(request) do
    [
      "+ Request#{get_content_type(request.headers)}\n",
      request.headers |> filter_content_type() |> print_headers() |> indent(4),
      request.response |> process_response()
    ] |> Enum.reject(&(&1 == "")) |> Enum.join("\n")
  end

  ## Responses

  @spec process_response(Response.t) :: String.t
  defp process_response(response) do
    [
      "+ Response #{response.status}#{get_content_type(response.headers)}\n",
      response.headers |> filter_content_type() |> print_headers() |> indent(4),
      response.body |> print_body() |> indent(4)
    ] |> Enum.reject(&(&1 == "")) |> Enum.join("\n")
  end

  @spec get_content_type([{String.t, String.t}]) :: String.t
  defp get_content_type([_|_] = headers) do
    case Enum.find(headers, fn({key, _}) -> key == "content-type" end) do
      {_, value} -> " (#{value})"
      _ -> ""
    end
  end
  defp get_content_type(_), do: ""

  ## Frontmatter

  @doc false
  @spec print_metadata(String.t) :: String.t
  def print_metadata(host), do: "FORMAT: 1A\nHOST: #{host}\n"

  @doc false
  @spec print_overview(String.t, String.t) :: String.t
  def print_overview(title, ""), do: "# #{title}\n"
  def print_overview(title, description), do: "# #{title}\n#{description}\n"

  ## Route Definition

  @spec print_route_definition(Route.t) :: String.t
  defp print_route_definition(route) do
    print_route_header(route.method, route.path, route.title)
    <> print_route_description(route.description)
  end

  @spec print_route_header(String.t, String.t, String.t | nil) :: String.t
  defp print_route_header(method, path, nil), do: "## #{method} #{path}\n"
  defp print_route_header(method, path, title) do
    "## #{title} [#{method} #{path}]\n"
  end

  @spec print_route_description(String.t | nil) :: String.t
  defp print_route_description(nil), do: ""
  defp print_route_description(description), do: "#{description}\n"

  ## Notes and Warnings

  @spec print_note(String.t | nil) :: String.t
  defp print_note(nil), do: ""
  defp print_note(note) do
    "::: note\n#{note}\n:::\n"
  end

  @spec print_warning(String.t | nil) :: String.t
  defp print_warning(nil), do: ""
  defp print_warning(warning) do
    "::: warning\n#{warning}\n:::\n"
  end

  ## Headers

  @doc false
  @spec print_headers([{String.t, String.t}]) :: String.t
  def print_headers([_|_] = headers) do
    "+ Headers\n\n"
    <> (headers |> Enum.map_join(&(print_header(&1))) |> indent(4))
  end
  def print_headers(_), do: ""

  @spec print_header({String.t, String.t}) :: String.t
  defp print_header({key, value}) do
    "#{key}: #{value}\n"
  end

  @spec filter_content_type([{String.t, String.t}]) :: [String.t]
  defp filter_content_type([_|_] = headers) do
    Enum.reject(headers, fn({key, _}) -> key == "content-type" end)
  end
  defp filter_content_type(_), do: []

  ## Body

  @spec print_body(String.t) :: String.t
  defp print_body(""), do: ""
  defp print_body(body) do
    "+ Body\n\n" <> (body |> indent(4)) <> "\n"
  end

  @spec indent(String.t, integer) :: String.t
  defp indent(str, count) do
    str
    |> String.split("\n")
    |> Enum.map(fn(line) ->
         case line do
            "" -> ""
            s -> String.duplicate(" ", count) <> s
          end
       end)
    |> Enum.join("\n")
  end
end
