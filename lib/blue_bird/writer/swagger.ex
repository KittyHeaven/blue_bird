defmodule BlueBird.Writer.Swagger do
  @moduledoc """
  Defines functions to convert `BlueBird.ApiDoc` struct into a Swagger json
  string.
  """
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
    |> put_info_desc(api_docs.description)

    Map.put(map, :info, info)
  end

  @spec put_info_desc(map, String.t) :: map
  defp put_info_desc(info, ""), do: info
  defp put_info_desc(info, desc), do: Map.put(info, :description, desc)
end
