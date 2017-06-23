defmodule BlueBird.Test.Writer do
  use BlueBird.Test.Support.ConnCase

  alias BlueBird.Route
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

  describe "group_routes/2" do
    test "groups routes" do
      route_a = %Route{group: "a"}
      route_b1 = %Route{group: "b"}
      route_b2 = %Route{group: "b"}
      route_c = %Route{group: "c"}

      routes = [route_b1, route_a, route_c, route_b2]

      expected = [
        {"a", [route_a]},
        {"b", [route_b1, route_b2]},
        {"c", [route_c]}
      ]

      assert Writer.group_routes(routes, :group) == expected
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
