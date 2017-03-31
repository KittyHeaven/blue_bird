defmodule BlueBird.ConnLogger do
  @moduledoc """
  BlueBird.ConnLogger caches `conn` sessions.
  """
  use GenServer

  def start_link do
    {:ok, _} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # --- Public Interface ---

  def conns, do: GenServer.call(__MODULE__, :conns)
  def reset, do: GenServer.call(__MODULE__, :reset)
  def save(conn), do: GenServer.cast(__MODULE__, {:save, conn})

  # --- Private Interface ---
  def handle_call(:conns, _from, conns), do: {:reply, conns, conns}
  def handle_call(:reset, _from, _conns), do: {:reply, [], []}
  def handle_cast({:save, conn}, conns), do: {:noreply, conns ++ [conn]}
end
