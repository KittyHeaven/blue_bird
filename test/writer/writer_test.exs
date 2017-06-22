defmodule BlueBird.Test.Writer do
  use BlueBird.Test.Support.ConnCase

  alias BlueBird.Test.Support.Examples
  alias BlueBird.Writer

  describe "run/1" do
    test "writes api doc to file" do
      alias BlueBird.Test.Support.Examples.Grouping

      Writer.run(Grouping.api_doc)

      path_apib = Path.join(["priv", "static", "docs", "api.apib"])
      path_swagger = Path.join(["priv", "static", "docs", "swagger.json"])

      assert {:ok, file} = File.read(path_apib)
      assert file == Grouping.apib

      assert {:ok, file} = File.read(path_swagger)
      assert file == Poison.encode!(Grouping.swagger)
    end
  end

  describe "example" do
    example_test Examples.Grouping
    example_test Examples.NoRoutes
    example_test Examples.NotesWarnings
    example_test Examples.Parameters
    example_test Examples.Requests
    example_test Examples.Responses
    example_test Examples.RouteTitles
    example_test Examples.Simple
  end
end
