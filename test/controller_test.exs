defmodule BlueBird.Test.ControllerTest do
  use BlueBird.Test.Support.ConnCase

  alias BlueBird.Parameter

  @parameter_error """
                   Wrong number of arguments for parameter option.
                   Expected either two or three arguments: The name, the type
                   and an optional keyword list. Correct usage:

                       parameter :name, :type

                       or

                       parameter :name, :type, [description: "description",
                                                optional: true]
                   """

  @parameter_type_error "The parameter macro expects a keyword list as " <>
                        "third argument."

  defmodule Docs do
    use BlueBird.Controller

    parameters [
      [:topic, :string, []]
    ]

    notes [
      [:no_customers, "Please don't use this route if you are a customer."]
    ]

    warnings [
      [:could_be_bad, "Could be really bad"]
    ]
  end

  defmodule Controller do
    use BlueBird.Controller

    apigroup "Bobtails", "The Bobtail Resource"

    api :GET, "/users" do
      group "Users"
      title "List all users"
      description "This route returns a list of all users."
      shared_item BlueBird.Test.ControllerTest.Docs.note(:no_customers)
      warning "May have undocumented side effects."
    end

    api :POST, "/users" do
      group "Users"
    end

    api :DELETE, "/users/:id" do end

    api :PUT, "/users/:id" do
      parameter :id, :integer, [default: "brownie", optional: true]
    end

    api :PATCH, "/users/:id/:pid/:topic" do
      parameter :id, :integer, [description: "the user ID"]
      parameter :pid, :integer, [description: "the post ID"]
      shared_item BlueBird.Test.ControllerTest.Docs.parameter(:topic)
      shared_item BlueBird.Test.ControllerTest.Docs.warning(:could_be_bad)
    end
  end

  describe "api/3" do
    test "expands to function returning a map" do
      assert Controller.api_doc("GET", "/users") == %BlueBird.Route{
        title: "List all users",
        description: "This route returns a list of all users.",
        note: "Please don't use this route if you are a customer.",
        warning: "May have undocumented side effects.",
        method: "GET",
        path: "/users",
        parameters: []
      }
    end

    test "expands with only one attribute" do
      assert %{path: "/users"} = Controller.api_doc("POST", "/users")
    end

    test "uses the right default values" do
      assert Controller.api_doc("DELETE", "/users/:id") == %BlueBird.Route{
        group: nil,
        title: nil,
        description: nil,
        note: nil,
        warning: nil,
        method: "DELETE",
        path: "/users/:id",
        parameters: []
      }
    end

    test "extracts a single parameter" do
      assert Controller.api_doc("PUT", "/users/:id").parameters == [
        %Parameter{
          description: nil,
          name: "`id`",
          type: "integer",
          default: "`brownie`",
          optional: true
        }
      ]
    end
    test "extracts all parameters" do
      path = "/users/:id/:pid/:topic"

      assert Controller.api_doc("PATCH", path).parameters == [
        %Parameter{
          description: "the user ID",
          name: "`id`",
          type: "integer"
        },
        %Parameter{
          description: "the post ID",
          name: "`pid`",
          type: "integer"
        },
        %Parameter{
          description: nil,
          name: "`topic`",
          type: "string"
        }
    ]
  end

  test "extracts shared warnings" do
    path = "/users/:id/:pid/:topic"

    assert Controller.api_doc("PATCH", path).warning === "Could be really bad"
  end

    test "raises error if single value fields have too many values" do
      message = "Expected single value for title, got 2"

      assert_compile_time_raise ArgumentError, message, fn ->
        import BlueBird.Controller

        api :POST, "/toomany" do
          title "too", "many"
        end
      end
    end

    test "raises error if parameter has invalid number of arguments" do
      assert_compile_time_raise ArgumentError, @parameter_error, fn ->
        import BlueBird.Controller

        api :POST, "/toofew" do
          parameter "bla"
        end
      end

      assert_compile_time_raise ArgumentError, @parameter_error, fn ->
        import BlueBird.Controller

        api :POST, "/toomany" do
          parameter "spam", :int, "eggs", "foo"
        end
      end
    end

    test "raises error if third parameter argument has wrong type" do
      assert_compile_time_raise ArgumentError, @parameter_type_error, fn ->
        import BlueBird.Controller

        api :POST, "/wrongtype" do
          parameter "this", "is", "wrong"
        end
      end
    end
  end
end
