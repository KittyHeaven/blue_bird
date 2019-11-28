defmodule BlueBird.Test.ConnLoggerTest do
  use BlueBird.Test.Support.ConnCase

  alias BlueBird.ConnLogger

  test "ConnLogger saves, returns and resets connections" do
    ConnLogger.reset()

    ConnLogger.save(build_conn(:get, "/read/mary_jane"))
    ConnLogger.save(build_conn(:get, "/read/jane_austen"))

    conns = ConnLogger.get_conns()

    assert conns
           |> Enum.map(& &1.request_path)
           |> Enum.sort() == ["/read/jane_austen", "/read/mary_jane"]

    ConnLogger.reset()

    assert ConnLogger.get_conns() == []
  end

  test "accepts additional options as :blue_bird_opts" do
    ConnLogger.reset()

    ConnLogger.save(build_conn(:get, "/read/jane_austen"),
      title: "No pride and no prejudice"
    )

    [conn] = ConnLogger.get_conns()

    assert conn.assigns == %{
             blue_bird_opts: [title: "No pride and no prejudice"]
           }
  end
end
