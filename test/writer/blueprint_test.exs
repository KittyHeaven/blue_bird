defmodule BlueBird.Test.Writer.BlueprintTest do
  use ExUnit.Case, async: true

  import BlueBird.Writer.Blueprint

  alias BlueBird.Test.Support.Examples
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
      headers = [{"accept", "application/json"}]
      assert print_headers(headers) ==
        """
        + Headers

            accept: application/json
        """
    end

    test "prints multiple headers" do
      headers = [
        {"accept", "application/json"},
        {"authorization", "I'm a bear"}
      ]
      assert print_headers(headers) ==
        """
        + Headers

            accept: application/json
            authorization: I'm a bear
        """
    end
  end

  describe "process_route/1" do
    test "prints header with method, title, path, and description" do
      result = process_route(%Route{
        method: "POST",
        path: "/path",
        title: "Get all",
        description: "This route gets all things.\n\nReally."
      })

      assert result == """
                       ## Get all [POST /path]
                       This route gets all things.

                       Really.
                       """
    end

    test "prints header with method and path, without title and description" do
      result = process_route(%Route{method: "POST", path: "/path"})

      assert result == "## POST /path\n"
    end

    test "prints note" do
      result = process_route(%Route{
        method: "POST",
        path: "/path",
        note: "This is important.\n\nVery."
      })
      assert result == """
                      ## POST /path

                      ::: note
                      This is important.

                      Very.
                      :::
                      """
    end

    test "prints warning" do
      result = process_route(%Route{
        method: "POST",
        path: "/path",
        warning: "This is important.\n\nEven more."
      })
      assert result == """
                      ## POST /path

                      ::: warning
                      This is important.

                      Even more.
                      :::
                      """
    end

    test "prints parameters" do
      result = process_route(%Route{
        method: "POST",
        path: "/path",
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
                       ## POST /path

                       + Parameters

                           + one (int, required) - The first parameter.

                           + two (string, required) - The second parameter.
                       """
    end

    test "prints requests" do
      result = process_route(%Route{
        method: "POST",
        path: "/path",
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
                       ## POST /path{?q}

                       + Request (application/json)

                           + Headers

                               accept: application/json

                       + Response 201 (application/json)

                           + Body

                               {"name":"George","kind":"dog"}

                       + Request

                           + Headers

                               accept: application/json

                       + Response 200 (application/json)

                           + Body

                               [{"name":"George","kind":"dog"}]
                       """
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

      assert group_routes(routes, :group) == expected
    end
  end

  describe "examples: " do
    def test_example(module) do
      assert generate_output(module.api_doc) == module.output
    end

    test "'Grouping' is rendered correctly" do
      test_example(Examples.Grouping)
    end

    test "'NotesWarnings' is rendered correctly" do
      test_example(Examples.NotesWarnings)
    end

    test "'Parameters' is rendered correctly" do
      test_example(Examples.Parameters)
    end

    test "'RouteTitles' is rendered correctly" do
      test_example(Examples.RouteTitles)
    end

    test "'Requests' is rendered correctly" do
      test_example(Examples.Requests)
    end

    test "'Responses' is rendered correctly" do
      test_example(Examples.Responses)
    end

    test "'Simple' is rendered correctly" do
      test_example(Examples.Simple)
    end
  end

  describe "run/1" do
    test "writes api doc to file" do
      alias BlueBird.Test.Support.Examples.Grouping

      run(Grouping.api_doc)

      path = Path.join(["priv", "static", "docs", "api.apib"])

      assert {:ok, file} = File.read(path)
      assert file == Grouping.output
    end
  end
end
