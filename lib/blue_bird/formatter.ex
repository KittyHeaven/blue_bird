defmodule BlueBird.Formatter do
  @moduledoc """
  `BlueBird.Formatter` has to be used as another ExUnit formatter.

  This module will catch the `:suite_finished` event (fired by `ExUnit`).
  Afterwards it will trigger the generation of the api blueprint file.

  ## Usage

  Add `BlueBird.Formatter` as a formatter in `test_helper.exs`.

      ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])
  """
  use GenEvent

  alias BlueBird.{BlueprintWriter, Generator}

  @doc """
  `init` function of this module.
  See https://hexdocs.pm/elixir/GenEvent.html#c:init/1.
  """
  def init(_config), do: {:ok, nil}

  @doc """
  Listen to events.

  If the event is `:suite_finished`, trigger the generation of api blueprint file.

  Ignore  all other events.
  """
  def handle_event({:suite_finished, _run_us, _load_us}, nil) do
    generate_blue_print_file()
    :remove_handler
  end

  def handle_event(_event, nil), do: {:ok, nil}

  defp generate_blue_print_file do
    Generator.run() |> BlueprintWriter.run()
  end
end
