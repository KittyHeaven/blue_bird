defmodule BlueBird.Test.ConfigTest do
  use ExUnit.Case

  alias BlueBird.Config

  describe "get/0" do
    test "returns all config for bluebird" do
      conf = Config.get()

      assert Keyword.get(conf, :aglio_path) == "aglio"
      assert Keyword.get(conf, :theme) ==  "triple"
      assert Keyword.get(conf, :ignore_headers) == ["ignore-me"]
      assert Keyword.get(conf, :pipelines) == [:api, :another_api]
      assert Keyword.get(conf, :router) == BlueBird.Test.Support.Router
      assert Keyword.get(conf, :docs_path) == "priv/static/docs"
    end
  end

  describe "get/1" do
    test "valid key" do
      assert Config.get(:aglio_path) == "aglio"
    end

    test "invalid key" do
      assert Config.get(:invalid_key) == nil
    end
  end

  describe "get/2" do
    test "valid key" do
      assert Config.get(:aglio_path, "default") == "aglio"
    end

    test "uses default value" do
      assert Config.get(:invalid_key, "default") == "default"
    end
  end
end
