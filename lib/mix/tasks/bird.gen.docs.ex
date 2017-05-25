defmodule Mix.Tasks.Bird.Gen.Docs do
  # todo: type specs
  use Mix.Task

  alias Mix.Project

  @shortdoc "Generates HTML API Docs from api.apib using Aglio"
  @moduledoc @shortdoc

  @doc false
  def run(_args) do
    if System.find_executable("aglio") == nil do
      raise "Install Aglio to convert Blueprint API to HTML: " <>
            "\"npm install aglio -g\""
    end

    docs_path = Application.get_env(:blue_bird, :docs_path, "docs")
    docs_theme = Application.get_env(:blue_bird, :docs_theme, "triple")

    project_path = Project.load_paths
    |> Enum.at(0)
    |> String.split("_build")
    |> Enum.at(0)

    path = Path.join(project_path, docs_path)

    System.cmd(
      "aglio",
      [
        "--theme-template",
        docs_theme,
        "-i",
        Path.join(path, "api.apib"),
        "-o",
        Path.join(path, "index.html")
      ]
    )
  end
end
