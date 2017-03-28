defmodule BlueBird.Formatter do
  use GenEvent

  def init(_config) do
    {:ok, nil}
  end

  def handle_event({:suite_finished, _run_us, _load_us}, nil) do
    save_blueprint_file()
    :remove_handler
  end

  def handle_event(_event, nil) do
    {:ok, nil}
  end

  defp save_blueprint_file do
    project_path = Mix.Project.load_paths |> Enum.at(0) |> String.split("_build") |> Enum.at(0)
    docs_path = Application.get_env(:blue_bird, :docs_path, "docs")
    path = Path.join(project_path, docs_path)

    api_docs = BlueBird.Generator.run

    BlueBird.BlueprintWriter.run(api_docs, path)
  end

end
