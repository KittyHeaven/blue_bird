defmodule BlueBird.Test.ConnLoggerTest do
  use BlueBird.Test.Support.ConnCase

  doctest BlueBird

  test "save/1" do
    BlueBird.ConnLogger.reset()
    BlueBird.ConnLogger.save(get_test_conn())

    assert BlueBird.ConnLogger.conns() == [get_test_conn()]
  end

  test "conns/0" do
    BlueBird.ConnLogger.reset()

    assert BlueBird.ConnLogger.conns() == []

    BlueBird.ConnLogger.save(get_test_conn())
    BlueBird.ConnLogger.save(get_test_conn())

    assert BlueBird.ConnLogger.conns() == [get_test_conn(), get_test_conn()]
  end

  defp get_test_conn do
    %{test: "test"}
  end
end
