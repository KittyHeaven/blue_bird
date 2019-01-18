defmodule BlueBird.Test.Writer.BlueprintTest do
  use BlueBird.Test.Support.ConnCase

  import BlueBird.Writer.Blueprint

  alias BlueBird.{ApiDoc, Parameter, Request, Response, Route}

  @complex_body %{
    string: "some value",
    number: 8,
    boolean: false,
    object: %{
      ac: :dc,
      name: "Martha",
      object_in_object: %{
        first_name: "A",
        second_name: "B"
      },
      likes: [
        "Apples",
        "Technology"
      ]
    },
    simple_list: [
      "Banana",
      "Apple"
    ],
    object_list: [
      %{key: "value"},
      %{key: "value2"}
    ]
  }

  test "print_metadata/1 prints metadata" do
    assert print_metadata("http://yo") == "FORMAT: 1A\nHOST: http://yo\n"
  end

  describe "print_overview/1" do
    test "prints overview with description" do
      api_doc = %ApiDoc{
        title: "Title",
        description: "One\nTwo"
      }

      assert print_overview(api_doc) == "# Title\nOne\nTwo\n"
    end

    test "prints overview without description" do
      api_doc = %ApiDoc{
        title: "Title"
      }

      assert print_overview(api_doc) == "# Title\n"
    end
  end

  describe "print_headers/1" do
    test "returns empty string for empty list" do
      assert print_headers([]) == ""
    end

    test "prints single header" do
      headers = [{"accept", "application/json"}]

      assert print_headers(headers) == """
             + Headers

                     accept: application/json
             """
    end

    test "prints multiple headers" do
      headers = [
        {"accept", "application/json"},
        {"authorization", "I'm a bear"}
      ]

      assert print_headers(headers) == """
             + Headers

                     accept: application/json
                     authorization: I'm a bear
             """
    end
  end

  describe "print_attributes/1" do
    test "prints empty attributes correctly" do
      assert print_attributes(%{}) == ""
    end

    test "prints attributes correctly" do
      assert print_attributes(@complex_body) == """
             + Attributes (object)

                     + boolean (string)
                     + number (number)
                     + object (object)
                         + ac (string)
                         + likes (array)
                         + name (string)
                         + object_in_object (object)
                             + first_name (string)
                             + second_name (string)
                     + object_list (array)
                         + (object)
                             + key (string)
                     + simple_list (array)
                     + string (string)
             """
    end
  end

  describe "process_route/1" do
    test "prints header with method, title, and description" do
      result =
        process_route(%Route{
          method: "POST",
          path: "/path",
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
      result = process_route(%Route{method: "POST", path: "/path"})

      assert result == "### POST\n"
    end

    test "prints note" do
      result =
        process_route(%Route{
          method: "POST",
          path: "/path",
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
      result =
        process_route(%Route{
          method: "POST",
          path: "/path",
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
      result =
        process_route(%Route{
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
             ### POST

             + Parameters

                 + one (int, required) - The first parameter.

                 + two (string, required) - The second parameter.
             """
    end

    test "prints requests" do
      result =
        process_route(%Route{
          method: "POST",
          path: "/users/:id/pets",
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
              path: "/users/:id/pets",
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

             + Request 201 (application/json)

                 + Headers

                         accept: application/json

                 + Attributes (object)

                         + kind (string)
                         + name (string)

                 + Body

                         {"kind":"dog","name":"George"}

             + Response 201 (application/json)

                 + Body

                         {"name":"George","kind":"dog"}

             + Request 200

                 + Headers

                         accept: application/json

             + Response 200 (application/json)

                 + Body

                         [{"name":"George","kind":"dog"}]
             """
    end
  end
end
