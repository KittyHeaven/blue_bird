defmodule BlueBird.Writer.Swagger do
  @moduledoc """
  Defines functions to convert `BlueBird.ApiDoc` struct into a Swagger json
  string.
  """
  import BlueBird.Writer, only: [group_routes: 2]

  alias BlueBird.{ApiDoc, Parameter, Request, Route}

  @doc """
  Generates a Swagger json string from a `BlueBird.ApiDocs{}` struct.
  """
  @spec generate_output(ApiDoc.t()) :: String.t()
  def generate_output(api_docs) do
    api_docs
    |> swagger_object()
    |> Poison.encode!()
  end

  @doc """
  Generates a map representation from a `BlueBird.ApiDocs{}` struct.
  """
  @spec swagger_object(ApiDoc.t()) :: map
  def swagger_object(api_docs) do
    %{}
    |> Map.put(:swagger, "2.0")
    |> Map.put(:info, info_object(api_docs))
    |> Map.merge(host_schemes_basepath(api_docs.host))
    |> Map.put(:paths, paths_object(api_docs.routes))
  end

  @doc false
  @spec info_object(ApiDoc.t()) :: map
  def info_object(api_docs) do
    %{}
    |> Map.put(:title, api_docs.title)
    |> Map.put(:version, "1")
    |> put_if_set(:description, api_docs.description)
    |> put_if_set(:termsOfService, api_docs.terms_of_service)
    |> put_if_set(:contact, contact_object(api_docs.contact))
    |> put_if_set(:license, license_object(api_docs.license))
  end

  @doc false
  @spec contact_object(keyword) :: map
  def contact_object(contact) do
    %{}
    |> put_if_set(:name, contact[:name])
    |> put_if_set(:url, contact[:url])
    |> put_if_set(:email, contact[:email])
  end

  @doc false
  @spec license_object(keyword) :: map
  def license_object(license) do
    %{}
    |> put_if_set(:name, license[:name])
    |> put_if_set(:url, license[:url])
  end

  @spec host_schemes_basepath(String.t()) :: map
  defp host_schemes_basepath(host) do
    uri = URI.parse(host)

    %{}
    |> put_if_set(:host, get_host(uri.host, uri.port))
    |> put_if_set(:schemes, [uri.scheme])
    |> put_if_set(:basePath, basePath(uri.path))
  end

  @doc false
  @spec get_host(String.t() | nil, String.t() | nil) :: String.t()
  defp get_host(host, nil), do: host
  defp get_host(host, port) when port == 80 or port == 443, do: host
  defp get_host(host, port), do: "#{host}:#{port}"

  @spec basePath(String.t() | nil) :: String.t()
  defp basePath(nil), do: "/"
  defp basePath(path), do: path

  @spec paths_object([Route.t()]) :: map
  def paths_object(routes) do
    routes
    |> group_routes(:path)
    |> Enum.reduce(%{}, fn {path, routes}, acc ->
         path = replace_path_params(path)
         Map.put(acc, path, path_item_object(routes))
       end)
  end

  @doc false
  @spec path_item_object([Route.t()]) :: map
  def path_item_object(routes) do
    routes
    |> group_routes(:method)
    |> Enum.reduce(%{}, fn {method, [route]}, acc ->
         Map.put(acc, String.downcase(method), operation_object(route))
       end)
  end

  @doc false
  @spec operation_object(Route.t()) :: map
  def operation_object(route) do
    %{}
    |> put_if_set(:summary, route.title)
    |> put_if_set(:description, route.description)
    |> put_if_set(:tags, [route.group])
    |> put_if_set(:consumes, content_types(route.requests, :request))
    |> put_if_set(:produces, content_types(route.requests, :response))
    |> put_if_set(:parameters, parameter_objects(route.parameters))
    |> Map.put(:responses, responses_object(route.requests))
  end

  @spec content_types([Request.t()], :request | :response) :: [String.t()]
  defp content_types(requests, type) do
    requests
    |> Enum.map(fn req ->
         headers =
           if type == :request, do: req.headers, else: req.response.headers

         headers
         |> Enum.filter(&(elem(&1, 0) == "content-type"))
         |> Enum.map(&elem(&1, 1))
       end)
    |> Enum.concat()
    |> Enum.uniq()
  end

  @doc false
  @spec responses_object([Request.t()]) :: map
  def responses_object(_requests) do
    %{}
  end

  @spec parameter_objects([Parameter.t()]) :: [map]
  defp parameter_objects(parameters) do
    Enum.map(parameters, &parameter_object(&1))
  end

  @doc false
  @spec parameter_object(Parameter.t()) :: map
  def parameter_object(parameter) do
    %{}
    |> put_if_set(:name, parameter.name)
    |> put_if_set(:description, parameter.description)
  end

  @spec replace_path_params(String.t()) :: String.t()
  defp replace_path_params(path) do
    ~r/:([\w]+)(\/|\z)/
    |> Regex.replace(path, "{\\1}/")
    |> String.trim_trailing("/")
  end

  @spec put_if_set(map, any, any) :: map
  defp put_if_set(map, _key, nil), do: map
  defp put_if_set(map, _key, ""), do: map
  defp put_if_set(map, _key, []), do: map
  defp put_if_set(map, _key, [nil]), do: map
  defp put_if_set(map, _key, value) when value == %{}, do: map
  defp put_if_set(map, key, value), do: Map.put(map, key, value)
end
