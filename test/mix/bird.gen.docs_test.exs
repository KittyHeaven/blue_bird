defmodule BlueBird.Test.Mix.BirdGenDocsTest do
  use BlueBird.Test.Support.ConnCase

  import Mix.Tasks.Bird.Gen.Docs

  alias BlueBird.ApiDoc

  test "bird.gen.docs generates html file" do
    path_apib = Path.join(["priv", "static", "docs", "index.html"])

    File.rm(path_apib)
    refute File.exists?(path_apib)

    run(%ApiDoc{})

    assert {:ok, file} = File.read(path_apib)
    assert file =~ "<title>Heavenly API</title>"
  end
end
