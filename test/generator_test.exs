defmodule GeneratorTest do
  use ExUnit.Case
  use Plug.Test

  doctest BlueBird

  @opts TestRouter.init([])

  test "get_app_module/0" do
    app_module = BlueBird.Generator.get_app_module
    assert app_module == BlueBird
  end

  test "get_router_module/1" do
    router_module = BlueBird.Generator.get_app_module
    |> BlueBird.Generator.get_router_module

    assert router_module == TestRouter
  end

  test "run/0" do
    BlueBird.ConnLogger.reset()

    assert BlueBird.Generator.run == %{
      description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        %{description: nil, group: "Test", method: "GET",
          note: nil, parameters: [], path: "/get", requests: [],
          title: "Test GET"},
        %{description: nil, group: "Test", method: "POST", note: "This is a note",
          parameters: [], path: "/post", requests: [],
          title: "Test POST"},
        %{description: nil, group: "Test", method: "PUT", note: nil,
          parameters: [], path: "/put", requests: [], title: "Test PUT"},
        %{description: nil, group: "Test", method: "PATCH", note: nil,
          parameters: [%{description: "Post ID or slug", name: "post_id", required: true, type: "integer"}],
          path: "/patch", requests: [],
          title: "Test PATCH"},
        %{description: nil, group: "Test", method: "DELETE", note: nil,
          parameters: [], path: "/delete", requests: [],
          title: "Test DELETE"}],
      title: "API Documentation"}
  end

  test "generator run with GET" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = conn(:get, "/get")
    |> put_req_header("accept", "application/json")
    |> put_req_header("accept-language", "de-de")

    # Invoke the plug
    conn = TestRouter.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        %{description: nil,
          group: "Test",
          method: "GET",
          note: nil,
          parameters: [],
          path: "/get",
          requests: [
            %{headers: [
                {"accept", "application/json"},
                {"accept-language", "de-de"}
              ],
              method: "GET",
              params: "{\"aspect\":\"params\"}",
              path: "/get",
              path_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 200
              }
            }
          ],
          title: "Test GET"
        },
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [],
          path: "/post",
          requests: [],
          title: "Test POST"
        },
        %{description: nil,
          group: "Test",
          method: "PUT",
          note: nil,
          parameters: [],
          path: "/put",
          requests: [],
          title: "Test PUT"
        },
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [
            %{description: "Post ID or slug",
              name: "post_id",
              required: true,
              type: "integer"
            }
          ],
          path: "/patch",
          requests: [],
          title: "Test PATCH"
        },
        %{description: nil,
          group: "Test",
          method: "DELETE",
          note: nil,
          parameters: [],
          path: "/delete",
          requests: [],
          title: "Test DELETE"
        }
      ],
      title: "API Documentation"
    }
  end

  test "generator run with POST" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = conn(:post, "/post", %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = TestRouter.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        %{description: nil,
          group: "Test",
          method: "GET",
          note: nil,
          parameters: [],
          path: "/get",
          requests: [],
          title: "Test GET"
        },
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [],
          path: "/post",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "POST",
              params: "{\"p\":5}",
              path: "/post",
              path_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test POST"
        },
        %{description: nil,
          group: "Test",
          method: "PUT",
          note: nil,
          parameters: [],
          path: "/put",
          requests: [],
          title: "Test PUT"
        },
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [
            %{description: "Post ID or slug",
              name: "post_id",
              required: true,
              type: "integer"
            }
          ],
          path: "/patch",
          requests: [],
          title: "Test PATCH"
        },
        %{description: nil,
          group: "Test",
          method: "DELETE",
          note: nil,
          parameters: [],
          path: "/delete",
          requests: [],
          title: "Test DELETE"
        }
      ],
      title: "API Documentation"
    }
  end

  test "generator run with PUT" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = conn(:put, "/put", %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = TestRouter.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        %{description: nil,
          group: "Test",
          method: "GET",
          note: nil,
          parameters: [],
          path: "/get",
          requests: [],
          title: "Test GET"
        },
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [],
          path: "/post",
          requests: [],
          title: "Test POST"
        },
        %{description: nil,
          group: "Test",
          method: "PUT",
          note: nil,
          parameters: [],
          path: "/put",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "PUT",
              params: "{\"p\":5}",
              path: "/put",
              path_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test PUT"
        },
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [
            %{description: "Post ID or slug",
              name: "post_id",
              required: true,
              type: "integer"
            }
          ],
          path: "/patch",
          requests: [],
          title: "Test PATCH"
        },
        %{description: nil,
          group: "Test",
          method: "DELETE",
          note: nil,
          parameters: [],
          path: "/delete",
          requests: [],
          title: "Test DELETE"
        }
      ],
      title: "API Documentation"
    }
  end

  test "generator run with PATCH" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = conn(:patch, "/patch", %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = TestRouter.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        %{description: nil,
          group: "Test",
          method: "GET",
          note: nil,
          parameters: [],
          path: "/get",
          requests: [],
          title: "Test GET"
        },
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [],
          path: "/post",
          requests: [],
          title: "Test POST"
        },
        %{description: nil,
          group: "Test",
          method: "PUT",
          note: nil,
          parameters: [],
          path: "/put",
          requests: [],
          title: "Test PUT"
        },
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [
            %{description: "Post ID or slug",
              name: "post_id",
              required: true,
              type: "integer"
            }
          ],
          path: "/patch",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "PATCH",
              params: "{\"p\":5}",
              path: "/patch",
              path_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test PATCH"
        },
        %{description: nil,
          group: "Test",
          method: "DELETE",
          note: nil,
          parameters: [],
          path: "/delete",
          requests: [],
          title: "Test DELETE"
        }
      ],
      title: "API Documentation"
    }
  end

  test "generator run with DELETE" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = conn(:delete, "/delete", %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = TestRouter.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 204

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        %{description: nil,
          group: "Test",
          method: "GET",
          note: nil,
          parameters: [],
          path: "/get",
          requests: [],
          title: "Test GET"
        },
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [],
          path: "/post",
          requests: [],
          title: "Test POST"
        },
        %{description: nil,
          group: "Test",
          method: "PUT",
          note: nil,
          parameters: [],
          path: "/put",
          requests: [],
          title: "Test PUT"
        },
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [
            %{description: "Post ID or slug",
              name: "post_id",
              required: true,
              type: "integer"
            }
          ],
          path: "/patch",
          requests: [],
          title: "Test PATCH"
        },
        %{description: nil,
          group: "Test",
          method: "DELETE",
          note: nil,
          parameters: [],
          path: "/delete",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "DELETE",
              params: "{\"p\":5}",
              path: "/delete",
              path_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 204
              }
            }
          ],
          title: "Test DELETE"
        }
      ],
      title: "API Documentation"
    }
  end
end
