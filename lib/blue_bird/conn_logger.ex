defmodule BlueBird.ConnLogger do
  use GenServer

  def start_link do
    {:ok, _} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def save(conn) do
    GenServer.cast(__MODULE__, {:save, conn})
    conn
  end

  def conns do
    GenServer.call(__MODULE__, :conns)
  end

  def init([]) do
    {:ok, []}
  end

  def handle_cast({:save, conn}, conns) do
    {:noreply, conns ++ [conn]}
  end

  def handle_call(:conns, _from, conns) do
    {:reply, conns, conns}
  end
end
