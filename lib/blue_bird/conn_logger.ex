defmodule BlueBird.ConnLogger do
  @moduledoc """
  Logs connections in test cases.

  `BlueBird.ConnLogger` is used to cache `%Plug.Conn` structs. To use it, you
  have to call `start/0` in `test/test_helper.exs`:

      BlueBird.start()
      ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])

  You can then use `BlueBird.ConnLogger.save(conn)` in your tests.

      defmodule MyApp.Web.UserControllerTest do
        use MyApp.Web.ConnCase

        alias BlueBird.ConnLogger

        test "returns a single user", %{conn: conn} do
          user = user_fixture()

          conn = conn
          |> get(conn, user_path(conn, :index, user.id))
          |> ConnLogger.save()

          assert json_response(conn, 200)["data"] == %{name: user.name}
        end
      end
  """
  use GenServer

  @doc """
  Starts the GenServer.

  Returns `{:ok, pid}` on success. Raises error on failure.

  ## Example

      iex> start_link()
      {:ok, #PID<0.80.0>}
  """
  @spec start_link :: {:ok, pid}
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
  @spec get_conns :: [Plug.Conn.t]
  def get_conns, do: GenServer.call(__MODULE__, :get_conns)

  @doc """
  Resets the logged connections.

  ## Example

      iex> reset()
      :ok
  """
  @spec reset :: :ok
  def reset, do: GenServer.call(__MODULE__, :reset)

  @doc """
  Saves the given connection to the list.

  ## Example

      iex> save(conn)
      :ok
  """
  @spec save(Plug.Conn.t) :: :ok
  def save(conn) do
    GenServer.cast(__MODULE__, {:save, conn})
    conn
  end

  ## Callbacks

  @doc false
  def handle_call(:get_conns, _from, conns), do: {:reply, conns, conns}

  @doc false
  def handle_call(:reset, _from, _conns), do: {:reply, [], []}

  @doc false
  def handle_cast({:save, conn}, conns), do: {:noreply, conns ++ [conn]}
end
