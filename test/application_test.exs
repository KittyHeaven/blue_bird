defmodule BlueBird.Test.ApplicationTest do
  use BlueBird.Test.Support.ConnCase

  test "start/1 sets options as environment variables" do
    opts = [a: "b", c: "a"]

    BlueBird.start(opts)

    assert Application.get_env(:blue_bird, :a) == "b"
    assert Application.get_env(:blue_bird, :c) == "a"
  end
end
