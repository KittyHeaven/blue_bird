defmodule BlueBird.Test.ConnLoggerTest do
  use ExUnit.Case

  alias BlueBird.ConnLogger

  @conn_1 %{mary: "jane"}
  @conn_2 %{jane: "austen"}

  test "ConnLogger saves, returns and resets connections" do
    ConnLogger.reset()

    ConnLogger.save(@conn_1)
    ConnLogger.save(@conn_2)

    assert ConnLogger.get_conns() == [@conn_1, @conn_2]

    ConnLogger.reset()

    assert ConnLogger.get_conns() == []
  end
end
