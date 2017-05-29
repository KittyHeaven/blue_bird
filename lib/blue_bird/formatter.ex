defmodule BlueBird.Formatter do
  @moduledoc """
  Catches the `:suite_finished` event fired by `ExUnit` and triggers the
  generation of the api blueprint file.

  `BlueBird.Formatter` has to be used as an ExUnit formatter.

  ## Usage

  Add `BlueBird.Formatter` as a formatter in `test_helper.exs`. Don't forget
  to add `BlueBird.start/0` as well.

      BlueBird.start()
      ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])
  """
  use GenEvent

  alias BlueBird.Writer.Blueprint
  alias BlueBird.Generator

  @doc """
  Initializes the handler when it is added to the GenEvent process.
  """
  @spec init(args :: term) :: {:ok, nil}
  def init(_config), do: {:ok, nil}

  @doc """
  Event listener that triggers the generation of the api blueprint file on when
  receiving a `:suite_finished` message by `ExUnit`.
  """
  @spec handle_event(event :: term, state :: term) ::
    {:ok, nil} | :remove_handler
  def handle_event({:suite_finished, _run_us, _load_us}, nil) do
    Generator.run() |> Blueprint.run()
    :remove_handler
  end
  def handle_event(_event, nil), do: {:ok, nil}
end
