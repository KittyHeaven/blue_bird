defmodule BlueBird.Writer do
  @moduledoc """
  Writes api documentations in apib and swagger format to files.
  """
  alias BlueBird.{ApiDoc, Config, Router}
  alias BlueBird.Writer.{Blueprint, Swagger}
  alias Mix.Project

  @doc """
  Writes a `BlueBird.ApiDoc{}` struct to apib and swagger files.

  This function will be called automatically by `BlueBird.Formatter` after
  every test run.

  You can set the destination directory in `config.exs`.

      config :blue_bird,
        docs_path: "priv/static/docs"
  """
  @spec run(ApiDoc.t()) :: :ok | {:error, File.posix()}
  def run(api_docs) do
    run_apib(api_docs, "api.apib")
    # run_swagger(api_docs, "swagger.json")
  end

  @spec run_apib(ApiDoc.t(), String.t()) :: {:error, File.posix()}
  def run_apib(api_docs, filename) do
    api_docs
    |> Blueprint.generate_output()
    |> write_file(filename)
  end

  @spec run_swagger(ApiDoc.t(), String.t()) :: {:error, File.posix()}
  def run_swagger(api_docs, filename) do
    api_docs
    |> Swagger.generate_output()
    |> write_file(filename)
  end

  @spec write_file(String.t(), String.t()) :: :ok | {:error, File.posix()}
  defp write_file(output, filename) do
    path = get_path()

    File.mkdir_p(path)

    path
    |> Path.join(filename)
    |> File.write(output)
  end

  @spec get_path :: binary
  defp get_path do
    docs_path = Config.get(:docs_path, "docs")

    Project.build_path()
    |> String.split("_build")
    |> Enum.at(0)
    |> Path.join(docs_path)
  end

  @doc false
  @spec group_routes([Route.t()], atom) :: [{String.t(), [Route.t()]}]
  def group_routes(routes, key) do
    routes
    |> Enum.group_by(fn route -> Map.get(route, key) end)
    |> Enum.to_list()
  end
end
