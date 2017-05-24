defmodule BlueBird.Test.ControllerTest do
  use ExUnit.Case

  defmodule Controller do
    use BlueBird.Controller

    api :GET, "/users" do
      group "Users"
      resource "User Collection"
      title "List all users"
      description "This route returns a list of all users."
      note "Please don't use this route if you are a customer."
    end

    api :POST, "/users" do
      group "Users"
    end

    api :DELETE, "/users/:id" do end

    api :PUT, "/users/:id" do
      parameter :id, :integer
    end

    api :PATCH, "/users/:id/:pid/:topic" do
      parameter :id, :integer, :required, "the user ID"
      parameter :pid, :integer, "the post ID"
      parameter :topic, :string, :required
    end
  end

  describe "api/3" do
    test "expands to function returning a map" do
      assert Controller.api_doc("GET", "/users") == %{
        group: "Users",
        resource: "User Collection",
        title: "List all users",
        description: "This route returns a list of all users.",
        note: "Please don't use this route if you are a customer.",
        method: "GET",
        path: "/users",
        parameters: []
      }
    end

    test "expands with only one attribute" do
      assert %{group: "Users"} = Controller.api_doc("POST", "/users")
    end

    test "uses the right default values" do
      assert Controller.api_doc("DELETE", "/users/:id") == %{
        group: nil,
        resource: nil,
        title: nil,
        description: nil,
        note: nil,
        method: "DELETE",
        path: "/users/:id",
        parameters: []
      }
    end

    test "extracts a single parameter" do
      assert Controller.api_doc("PUT", "/users/:id")[:parameters] == [%{
        description: nil,
        name: "id",
        required: false,
        type: "integer"
      }]
    end
    test "extracts all parameters" do
      path = "/users/:id/:pid/:topic"

      assert Controller.api_doc("PATCH", path)[:parameters] == [%{
        description: "the user ID",
        name: "id",
        required: true,
        type: "integer"
      }, %{
        description: "the post ID",
        name: "pid",
        required: false,
        type: "integer"
      }, %{
        description: nil,
        name: "topic",
        required: true,
        type: "string"
      }]
    end

    test "raises error if single value fields have too many values"
    test "raises error if path parameters are missing"
    test "raises error if parameter is not in path"
  end
end
