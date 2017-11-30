defmodule Mix.Tasks.Bird.Gen.Examples do
  @moduledoc """
  Renders the example tests as apib or swagger files.
  """
  use Mix.Task

  alias Mix.Project
  alias BlueBird.Test.Support.Examples
  alias BlueBird.Writer

  @doc false
  def run(_args) do
    if System.find_executable("aglio") == nil do
      raise "Install Aglio to convert Blueprint API to HTML: " <>
              "\"npm install aglio -g\""
    end

    docs_path = Application.get_env(:blue_bird, :docs_path, "docs")
    docs_theme = Application.get_env(:blue_bird, :docs_theme, "triple")

    project_path =
      Project.load_paths()
      |> Enum.at(0)
      |> String.split("_build")
      |> Enum.at(0)

    path = Path.join(project_path, docs_path)

    examples = [
      Examples.Grouping,
      Examples.NoRoutes,
      Examples.NotesWarnings,
      Examples.Parameters,
      Examples.Requests,
      Examples.Responses,
      Examples.RouteTitles,
      Examples.Simple
    ]

    Enum.map(examples, fn e ->
      name = module_to_title(e)
      filename_swagger = "swagger_#{name}.json"
      filename_apib = "#{name}.apib"

      e.api_doc() |> Writer.run_swagger(filename_swagger)
      e.api_doc() |> Writer.run_apib(filename_apib)

      System.cmd("aglio", [
        "--theme-template",
        docs_theme,
        "-i",
        Path.join(path, filename_apib),
        "-o",
        Path.join(path, "#{name}.html")
      ])
    end)
  end

  defp module_to_title(module), do: module |> Module.split() |> Enum.at(-1)
end
