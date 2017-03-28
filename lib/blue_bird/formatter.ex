defmodule BlueBird.Formatter do
  use GenEvent

  @project_path Mix.Project.load_paths |> Enum.at(0) |> String.split("_build") |> Enum.at(0)
  @docs_path    Application.get_env(:blue_bird, :docs_path, "docs")

  def init(_config), do: {:ok, nil}

  def handle_event({:suite_finished, _run_us, _load_us}, nil) do
    save_blueprint_file()
    :remove_handler
  end

  def handle_event(_event, nil), do: {:ok, nil}

  defp save_blueprint_file do
    BlueBird.Generator.run()
    |> BlueBird.BlueprintWriter.run(Path.join(@project_path, @docs_path))
  end
end
