defmodule BlueBird.Writer.Swagger do
  @moduledoc """
  Defines functions to convert `BlueBird.ApiDoc` struct into a Swagger json
  string.
  """
  import BlueBird.Writer, only: [group_routes: 2]

  alias BlueBird.{ApiDoc, Parameter, Request, Route}

  @ignore_headers Application.get_env(:blue_bird, :ignore_headers, [])

  @doc """
  Generates a Swagger json string from an `BlueBird.ApiDocs{}` struct.
  """
  @spec generate_output(ApiDoc.t) :: String.t
  def generate_output(api_docs) do
    %{}
    |> put_version
    |> put_host(api_docs)
    |> put_info(api_docs)
    |> put_paths(api_docs)
    |> Poison.encode!
  end

  @spec put_version(map) :: map
  defp put_version(map), do: Map.put(map, :swagger, "2.0")

  @spec put_host(map, ApiDoc.t) :: map
  defp put_host(map, api_docs) do
    uri = URI.parse(api_docs.host)

    Map.merge(
      map,
      %{
        host: uri.host,
        schemes: [uri.scheme],
        basePath: basePath(uri.path)
      }
    )
  end

  @spec basePath(String.t | nil) :: String.t
  defp basePath(nil), do: "/"
  defp basePath(path), do: path

  @spec put_info(map, ApiDoc.t) :: map
  defp put_info(map, api_docs) do
    info = %{title: api_docs.title, version: "1"}
    |> put_if_set(:description, api_docs.description)
    |> put_if_set(:termsOfService, api_docs.terms_of_service)
    |> put_contact(api_docs.contact)
    |> put_license(api_docs.license)

    Map.put(map, :info, info)
  end

  @spec put_contact(map, [name: String.t, url: String.t, email: String.t])
    :: map
  defp put_contact(map, [name: "", url: "", email: ""]), do: map
  defp put_contact(map, contact) do
    contact_map = %{}
    |> put_if_set(:name, contact[:name])
    |> put_if_set(:url, contact[:url])
    |> put_if_set(:email, contact[:email])

    Map.put(map, :contact, contact_map)
  end

  @spec put_license(map, [name: String.t, url: String.t]) :: map
  defp put_license(map, [name: "", url: ""]), do: map
  defp put_license(map, license) do
    license_map = %{}
    |> put_if_set(:name, license[:name])
    |> put_if_set(:url, license[:url])

    Map.put(map, :license, license_map)
  end

  @spec put_paths(map, ApiDoc.t) :: map
  defp put_paths(map, api_docs) do
    paths = api_docs.routes
    |> group_routes(:path)
    |> Enum.reduce(%{}, fn({path, routes}, acc) ->
         path = replace_path_params(path)
         Map.put(acc, path, path_item_object(routes))
       end)

    Map.put(map, :paths, paths)
  end

  @spec path_item_object([Route.t]) :: map
  defp path_item_object(routes) do
    routes
    |> group_routes(:method)
    |> Enum.reduce(%{}, fn({method, [route]}, acc) ->
         Map.put(acc, String.downcase(method), operation_object(route))
       end)
  end

  @spec operation_object(Route.t) :: map
  defp operation_object(route) do
    %{}
    |> put_if_set(:summary, route.title)
    |> put_if_set(:description, route.description)
    |> put_if_set(:tags, [route.group])
    |> put_if_set(:parameters, parameter_objects(route))
  end

  @spec parameter_objects(Route.t) :: map
  defp parameter_objects(route) do
    route.parameters
    |> Enum.map(fn(parameter) ->
      %{}
      |> put_if_set(:name, parameter.name)
      |> put_if_set(:description, parameter.description)
    end)
  end

  @spec replace_path_params(String.t) :: String.t
  defp replace_path_params(path) do
    ~r/:([\w]+)(\/|\z)/
    |> Regex.replace(path, "{\\1}/")
    |> String.trim_trailing("/")
  end

  @spec put_if_set(map, any, any) :: map
  defp put_if_set(map, key, nil), do: map
  defp put_if_set(map, key, ""), do: map
  defp put_if_set(map, key, []), do: map
  defp put_if_set(map, key, [nil]), do: map
  defp put_if_set(map, key, value), do: Map.put(map, key, value)
end
