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
  use GenServer

  alias BlueBird.Generator
  alias BlueBird.Writer

  @doc """
  Initializes the handler.
  """
  @spec init(args :: term) :: {:ok, nil}
  def init(_config), do: {:ok, nil}

  @doc """
  Event listener that triggers the generation of the api blueprint file when
  receiving a `:suite_finished` message by `ExUnit`.
  """
  @spec handle_cast(request :: term, state :: term) :: {:noreply, nil}
  def handle_cast({:suite_finished, _run_us, _load_us}, _state) do
    IO.puts "Tests finished"
    Generator.run() |> Writer.run()
    {:noreply, nil}
  end

  def handle_cast(_, _), do: {:noreply, nil}
end
