defmodule BlueBird.Formatter do
  @moduledoc """
  `BlueBird.Formatter` has to be another ExUnit formatter.

  This module will catch the `:suite_finished` event (fired by `ExUnit`). Afterwards it will trigger
  the generation of the api blueprint file.

  Usage: In your `test_helper.exs` add `BlueBird.Formatter` as formatter.
  It shoud look like: `ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])`.
  """
  use GenEvent

  @docs_path Application.get_env(:blue_bird, :docs_path, "docs")

  @doc """
  `init` function of this module.
  See `https://hexdocs.pm/elixir/GenEvent.html#c:init/1`
  """
  def init(_config), do: {:ok, nil}

  @doc """
  When the tests suite did its job, trigger the file generator.
  """
  def handle_event({:suite_finished, _run_us, _load_us}, nil) do
    save_blueprint_file()
    :remove_handler
  end

  @doc """
  Ignore all other events.
  """
  def handle_event(_event, nil), do: {:ok, nil}

  defp save_blueprint_file do
    project_path = Mix.Project.load_paths
    |> Enum.at(0)
    |> String.split("_build")
    |> Enum.at(0)

    BlueBird.Generator.run()
    |> BlueBird.BlueprintWriter.run(Path.join(project_path, @docs_path))
  end
end
