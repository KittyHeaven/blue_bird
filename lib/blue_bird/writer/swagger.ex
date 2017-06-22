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
    |> Poison.encode!
  end

  defp put_version(map), do: Map.put(map, :swagger, "2.0")

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

  defp basePath(nil), do: "/"
  defp basePath(path), do: path
end
