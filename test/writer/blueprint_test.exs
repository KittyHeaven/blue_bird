defmodule BlueBird.Test.Writer.BlueprintTest do
  use ExUnit.Case, async: true

  import BlueBird.Writer.Blueprint

  alias BlueBird.{Parameter, Request, Response, Route}

  test "print_metadata/1 prints metadata" do
    assert print_metadata("http://yo") == "FORMAT: 1A\nHOST: http://yo\n"
  end

  describe "print_overview/2" do
    test "prints overview with description" do
      assert print_overview("Title", "One\nTwo") == "# Title\nOne\nTwo\n"
    end

    test "prints overview without description" do
      assert print_overview("Title", "") == "# Title\n"
    end
  end

  describe "print_headers/1" do
    test "returns empty string for empty list" do
      assert print_headers([]) == ""
    end

    test "prints single header" do
      headers = [{"content-type", "application/json"}]
      assert print_headers(headers) ==
        """
        + Headers

            content-type: application/json
        """
    end

    test "prints multiple headers" do
      headers = [
        {"content-type", "application/json"},
        {"authorization", "I'm a bear"}
      ]
      assert print_headers(headers) ==
        """
        + Headers

            content-type: application/json
            authorization: I'm a bear
        """
    end
  end

  describe "process_route/1" do
    test "prints header with method, title, and description" do
      result = process_route(%Route{
        method: "POST",
        title: "Get all",
        description: "This route gets all things.\n\nReally."
      })

      assert result == """
                       ### Get all [POST]
                       This route gets all things.

                       Really.
                       """
    end

    test "prints header with method, without title and description" do
      assert process_route(%Route{method: "POST"}) == "### POST\n"
    end

    test "prints note" do
      result = process_route(%Route{
        method: "POST",
        note: "This is important.\n\nVery."
      })
      assert result == """
                      ### POST

                      ::: note
                      This is important.

                      Very.
                      :::
                      """
    end

    test "prints warning" do
      result = process_route(%Route{
        method: "POST",
        warning: "This is important.\n\nEven more."
      })
      assert result == """
                      ### POST

                      ::: warning
                      This is important.

                      Even more.
                      :::
                      """
    end

    test "prints parameters" do
      result = process_route(%Route{
        method: "POST",
        parameters: [
          %Parameter{
            name: "one",
            type: "int",
            description: "The first parameter."
          },
          %Parameter{
            name: "two",
            type: "string",
            description: "The second parameter."
          }
        ]
      })

      assert result == """
                       ### POST

                           + Parameters

                               + one: (int, required) - The first parameter.

                               + two: (string, required) - The second parameter.
                       """
    end

    test "prints requests" do
      result = process_route(%Route{
        method: "POST",
        requests: [
          %Request{
            method: POST,
            path: "/users/:id/pets",
            headers: [
              {"accept", "application/json"},
              {"content-type", "application/json"}
            ],
            path_params: %{"id" => "137"},
            body_params: %{"name" => "George", "kind" => "dog"},
            query_params: %{},
            response: %Response{
              status: 201,
              headers: [{"content-type", "application/json"}],
              body: "{\"name\":\"George\",\"kind\":\"dog\"}"
            }
          },
          %Request{
            method: POST,
            path: "/pets",
            headers: [{"accept", "application/json"}],
            path_params: %{},
            body_params: %{},
            query_params: %{"q" => "good boy"},
            response: %Response{
              status: "200",
              headers: [{"content-type", "application/json"}],
              body: "[{\"name\":\"George\",\"kind\":\"dog\"}]"
            }
          }
        ]
      })

      assert result == """
                       ### POST

                           + Request

                               + Headers

                                   accept: application/json
                                   content-type: application/json

                           + Response 201

                               + Headers

                                   content-type: application/json

                               + Body

                                   {"name":"George","kind":"dog"}

                           + Request

                               + Headers

                                   accept: application/json

                           + Response 200

                               + Headers

                                   content-type: application/json

                               + Body

                                   [{"name":"George","kind":"dog"}]
                       """
    end
  end

  describe "group_routes_by_key/2" do
    test "groups routes by group" do
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

      assert group_routes_by_key(routes, :group) == expected
    end
  end

  describe "group_routes/1 " do
    test "groups routes by group and path" do
      route_a = %Route{group: "Group A", path: "/one"}
      route_b1 = %Route{group: "Group B", path: "/two"}
      route_b2 = %Route{group: "Group B", path: "/one"}
      route_b3 = %Route{group: "Group B", path: "/two"}
      route_c = %Route{group: "Group C", path: "/one"}

      routes = [route_b1, route_a, route_b3, route_c, route_b2]

      expected = [
          {
            "Group A", [
              {"/one", [route_a]}
            ]
          },
          {
            "Group B", [
              {"/one", [route_b2]},
              {"/two", [route_b1, route_b3]}
            ]
          },
          {
            "Group C", [
              {"/one", [route_c]}
            ]
          }
        ]

        assert group_routes(routes) == expected
    end
  end

  describe "Example" do
    alias BlueBird.Test.Support.Examples.Grouping
    alias BlueBird.Test.Support.Examples.NamedAction
    alias BlueBird.Test.Support.Examples.Requests
    alias BlueBird.Test.Support.Examples.Responses
    alias BlueBird.Test.Support.Examples.Simple

    test "Simple is rendered correctly" do
      assert generate_output(Simple.api_doc) == Simple.output
    end

    test "NamedAction is rendered correctly" do
      assert generate_output(NamedAction.api_doc) == NamedAction.output
    end

    test "Grouping is rendered correctly" do
      assert generate_output(Grouping.api_doc) == Grouping.output
    end

    test "Responses is rendered correctly" do
      assert generate_output(Responses.api_doc) == Responses.output
    end

    test "Requests is rendered correctly" do
      assert generate_output(Requests.api_doc) == Requests.output
    end
  end
end
