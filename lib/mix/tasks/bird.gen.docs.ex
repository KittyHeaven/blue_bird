defmodule Mix.Tasks.Bird.Gen.Docs do
  @moduledoc """
  Generates HTML API Docs from api.apib using aglio.

  This task uses [Aglio](https://github.com/danielgtaylor/aglio) to render the
  file. To install, run `npm install aglio -g`.
  """
  use Mix.Task

  alias Mix.Project

  @aglio_default "aglio"

  @aglio_missing """
  Install Aglio to convert Blueprint API to HTML:

  - `npm install aglio -g` to install it globally on your system.

  - `npm install aglio` in your prefered location, then use e.g.

  `config :blue_bird, aglio_path: "node_modules/.bin/aglio"` to configure the path to it.
  """

  @doc false
  def run(_args) do
    aglio_path =
      case Application.get_env(:blue_bird, :aglio_path, @aglio_default) do
        @aglio_default ->
          if System.find_executable(@aglio_default) == nil do
            raise @aglio_missing
          end

          @aglio_default

        local_path ->
          absolute_local_path = Path.absname(local_path)

          if File.exists?(absolute_local_path) == false do
            raise @aglio_missing
          end

          absolute_local_path
      end

    docs_path = Application.get_env(:blue_bird, :docs_path, "docs")
    docs_theme = Application.get_env(:blue_bird, :docs_theme, "triple")

    path =
      Project.build_path()
      |> String.split("_build")
      |> Enum.at(0)
      |> Path.join(docs_path)

    System.cmd(aglio_path, [
      "--theme-template",
      docs_theme,
      "-i",
      Path.join(path, "api.apib"),
      "-o",
      Path.join(path, "index.html")
    ])
  end
end
