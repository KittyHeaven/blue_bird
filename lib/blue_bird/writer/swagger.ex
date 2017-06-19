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
  def generate_output(_api_docs) do
    %{swagger: "2.0"}
    |> Poison.encode!
  end
end
