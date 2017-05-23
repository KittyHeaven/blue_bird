defmodule BlueBird.Plug do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    {:ok, body, a} = Plug.Conn.read_body conn
    IO.inspect a
    Map.put(conn, :testinator, body)
  end
end
