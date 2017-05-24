defmodule BlueBird.ConnLogger do
  @moduledoc """
  `BlueBird.ConnLogger` caches `conn` sessions.
  """
  use GenServer

  def start_link do
    {:ok, _} = GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## Public Interface

  @doc """
  Returns the logged connections.

  ## Example

      iex> get_conns()
      [%Plug.Conn{}, ...]
  """
  def get_conns, do: GenServer.call(__MODULE__, :get_conns)

  @doc """
  Resets the logged connections.

  ## Example

      iex> reset()
      :ok
  """
  def reset, do: GenServer.call(__MODULE__, :reset)

  @doc """
  Saves the given connection to the list.

  ## Example

      iex> save(conn)
      :ok
  """
  def save(conn), do: GenServer.cast(__MODULE__, {:save, conn})

  ## Callbacks

  def handle_call(:get_conns, _from, conns), do: {:reply, conns, conns}
  def handle_call(:reset, _from, _conns), do: {:reply, [], []}
  def handle_cast({:save, conn}, conns), do: {:noreply, conns ++ [conn]}
end
