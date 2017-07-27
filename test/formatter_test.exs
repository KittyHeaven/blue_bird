defmodule BlueBird.Test.FormatterTest do
  use ExUnit.Case

  alias BlueBird.Formatter

  test "Formatter runs Generator and Writer" do
    path_apib = Path.join(["priv", "static", "docs", "api.apib"])
    path_swagger = Path.join(["priv", "static", "docs", "swagger.json"])

    File.rm(path_apib)
    File.rm(path_swagger)

    refute File.exists?(path_apib)
    refute File.exists?(path_swagger)

    assert Formatter.handle_cast({:suite_finished, 1, 2}, nil) ==
      {:noreply, nil}

    assert {:ok, file} = File.read(path_apib)
    assert file =~ "HOST: https://justiceisusefulwhenmoneyisuseless.fake"

    assert {:ok, file} = File.read(path_swagger)
    assert file =~ "\"host\":\"justiceisusefulwhenmoneyisuseless.fake\""
  end
end
