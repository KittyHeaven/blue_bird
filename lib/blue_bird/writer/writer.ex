defmodule BlueBird.Writer do
  @moduledoc """
  Writes api documentations in apib and swagger format to files.
  """
  alias BlueBird.ApiDoc
  alias BlueBird.Writer.Blueprint
  alias BlueBird.Writer.Swagger
  alias Mix.Project

  @docs_path Application.get_env(:blue_bird, :docs_path, "docs")

  @doc """
  Writes a `BlueBird.ApiDoc{}` struct to apib and swagger files.

  This function will be called automatically by `BlueBird.Formatter` after
  every test run.

  You can set the destination directory in `config.exs`.

      config :blue_bird,
        docs_path: "priv/static/docs"
  """
  @spec run(ApiDoc.t) :: :ok | {:error, File.posix}
  def run(api_docs) do
    run_apib(api_docs, "api.apib")
    run_swagger(api_docs, "swagger.json")
  end

  def run_apib(api_docs, filename) do
    api_docs
    |> Blueprint.generate_output()
    |> write_file(filename)
  end

  def run_swagger(api_docs, filename) do
    api_docs
    |> Swagger.generate_output()
    |> write_file(filename)
  end

  @spec write_file(String.t, String.t) :: :ok | {:error, File.posix}
  defp write_file(output, filename) do
    path = get_path()

    File.mkdir_p(path)

    path
    |> Path.join(filename)
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
end
