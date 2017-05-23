defmodule BlueBird.Test.GeneratorTest do
  use BlueBird.Test.Support.ConnCase

  alias BlueBird.Test.Support.Router

  doctest BlueBird

  @opts Router.init([])

  test "get_app_module/0" do
    app_module = BlueBird.Generator.get_app_module
    assert app_module == BlueBird
  end

  test "BlueBird.Generator.get_router_module/1" do
    router_module = BlueBird.Generator.get_app_module
    |> BlueBird.Generator.get_router_module

    assert router_module == Router
  end

  test "BlueBird.Generator.run/0" do
    BlueBird.ConnLogger.reset()

    assert BlueBird.Generator.run == %{
      description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      title: "API Documentation",
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
          requests: [],
          method: "GET",
          note: nil,
          parameters: [
            %{description: "GET param",
              name: "param",
              required: true,
              type: "integer"
          }],
          path: "/get/:param",
          title: "Test GET with param"
        },
        %{description: nil,
          group: "Test",
          parameters: [],
          requests: [],
          method: "POST",
          note: "This is a note",
          path: "/post",
          title: "Test POST"
        },
        %{description: nil,
          group: "Test",
          requests: [],
          method: "POST",
          note: "This is a note",
          parameters: [
            %{required: true,
              type: "integer",
              description: "Post param",
              name: "param"
          }],
          path: "/post/:param",
          title: "Test POST with param"
        },
        %{description: nil,
          group: "Test",
          note: nil,
          parameters: [],
          requests: [],
          method: "PUT",
          path: "/put",
          title: "Test PUT"
        },
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [],
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
      ]
    }
  end

  @tag :get
  test "BlueBird.Generator.run/0 GET" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:get, "/get")
    |> put_req_header("accept", "application/json")
    |> put_req_header("accept-language", "de-de")

    # Invoke the plug
    conn = Router.call(conn, @opts)

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
              body_params: %{},
              path: "/get",
              path_params: %{},
              query_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 200
              }
            }
          ],
          title: "Test GET"
        },
        empty_get_with_param_route(),
        empty_post_route(),
        empty_post_with_param_route(),
        empty_put_route(),
        empty_patch_route(),
        empty_delete_route()
      ],
      title: "API Documentation"
    }
  end

  @tag :get
  test "BlueBird.Generator.run/0 GET (with params)" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:get, "/get/3")
    |> put_req_header("accept", "application/json")
    |> put_req_header("accept-language", "de-de")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        empty_get_route(),
        %{description: nil,
          group: "Test",
          method: "GET",
          note: nil,
          parameters: [
            %{description: "GET param",
              name: "param",
              required: true,
              type: "integer"
          }],
          path: "/get/:param",
          requests: [
            %{headers: [
                {"accept", "application/json"},
                {"accept-language", "de-de"}
              ],
              method: "GET",
              body_params: %{},
              path: "/get/:param",
              path_params: %{"param" => "3"},
              query_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 200
              }
            }
          ],
          title: "Test GET with param"
        },
        empty_post_route(),
        empty_post_with_param_route(),
        empty_put_route(),
        empty_patch_route(),
        empty_delete_route()
      ],
      title: "API Documentation"
    }
  end

  @tag :post
  test "BlueBird.Generator.run/0 POST" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:post, "/post", Poison.encode! %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        empty_get_route(),
        empty_get_with_param_route(),
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [],
          path: "/post",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "POST",
              body_params: %{"p" => 5},
              path: "/post",
              path_params: %{},
              query_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test POST"
        },
        empty_post_with_param_route(),
        empty_put_route(),
        empty_patch_route(),
        empty_delete_route()
      ],
      title: "API Documentation"
    }
  end

  @tag :post
  test "BlueBird.Generator.run/0 POST (with params)" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:post, "/post/5", Poison.encode! %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        empty_get_route(),
        empty_get_with_param_route(),
        empty_post_route(),
        %{description: nil,
          group: "Test",
          method: "POST",
          note: "This is a note",
          parameters: [
            %{description: "Post param",
              name: "param",
              required: true,
              type: "integer"
          }],
          path: "/post/:param",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "POST",
              body_params: %{"p" => 5},
              path: "/post/:param",
              path_params: %{"param" => "5"},
              query_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test POST with param"
        },
        empty_put_route(),
        empty_patch_route(),
        empty_delete_route()
      ],
      title: "API Documentation"
    }
  end

  @tag :put
  test "BlueBird.Generator.run/0 PUT" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:put, "/put", Poison.encode! %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        empty_get_route(),
        empty_get_with_param_route(),
        empty_post_route(),
        empty_post_with_param_route(),
        %{description: nil,
          group: "Test",
          method: "PUT",
          note: nil,
          parameters: [],
          path: "/put",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "PUT",
              body_params: %{"p" => 5},
              path: "/put",
              path_params: %{},
              query_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test PUT"
        },
        empty_patch_route(),
        empty_delete_route()
      ],
      title: "API Documentation"
    }
  end

  @tag :patch
  test "BlueBird.Generator.run/0 PATCH" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:patch, "/patch", Poison.encode! %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        empty_get_route(),
        empty_get_with_param_route(),
        empty_post_route(),
        empty_post_with_param_route(),
        empty_put_route(),
        %{description: nil,
          group: "Test",
          method: "PATCH",
          note: nil,
          parameters: [],
          path: "/patch",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "PATCH",
              body_params: %{"p" => 5},
              path: "/patch",
              path_params: %{},
              query_params: %{},
              response: %{
                body: "{\"status\":\"ok\"}",
                headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                status: 201
              }
            }
          ],
          title: "Test PATCH"
        },
        empty_delete_route(),
      ],
      title: "API Documentation"
    }
  end

  @tag :delete
  test "BlueBird.Generator.run/0 DELETE" do
    BlueBird.ConnLogger.reset()

    # Create a test connection
    conn = build_conn(:delete, "/delete", Poison.encode! %{p: 5})
    |> put_req_header("content-type", "application/json")

    # Invoke the plug
    conn = Router.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 204

    BlueBird.ConnLogger.save(conn)

    assert BlueBird.Generator.run() ==
    %{description: "Enter API description in mix.exs - blue_bird_info",
      host: "http://localhost",
      routes: [
        empty_get_route(),
        empty_get_with_param_route(),
        empty_post_route(),
        empty_post_with_param_route(),
        empty_put_route(),
        empty_patch_route(),
        %{description: nil,
          group: "Test",
          method: "DELETE",
          note: nil,
          parameters: [],
          path: "/delete",
          requests: [
            %{headers: [{"content-type", "application/json"}],
              method: "DELETE",
              body_params: %{"p" => 5},
              path: "/delete",
              path_params: %{},
              query_params: %{},
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

  defp empty_get_route do
    %{description: nil,
      group: "Test",
      method: "GET",
      note: nil,
      parameters: [],
      path: "/get",
      requests: [],
      title: "Test GET"
    }
  end

  defp empty_get_with_param_route do
    %{description: nil,
      group: "Test",
      method: "GET",
      note: nil,
      parameters: [
        %{description: "GET param",
          name: "param",
          required: true,
          type: "integer"
      }],
      path: "/get/:param",
      requests: [],
      title: "Test GET with param"
    }
  end

  defp empty_post_route do
    %{description: nil,
      group: "Test",
      method: "POST",
      note: "This is a note",
      parameters: [],
      path: "/post",
      requests: [],
      title: "Test POST"
    }
  end

  defp empty_post_with_param_route do
    %{description: nil,
      group: "Test",
      method: "POST",
      note: "This is a note",
      parameters: [
        %{description: "Post param",
          name: "param",
          required: true,
          type: "integer"
      }],
      path: "/post/:param",
      requests: [],
      title: "Test POST with param"
    }
  end

  defp empty_put_route do
    %{description: nil,
      group: "Test",
      method: "PUT",
      note: nil,
      parameters: [],
      path: "/put",
      requests: [],
      title: "Test PUT"
    }
  end

  defp empty_patch_route do
    %{description: nil,
      group: "Test",
      method: "PATCH",
      note: nil,
      parameters: [],
      path: "/patch",
      requests: [],
      title: "Test PATCH"
    }
  end

  defp empty_delete_route do
    %{description: nil,
      group: "Test",
      method: "DELETE",
      note: nil,
      parameters: [],
      path: "/delete",
      requests: [],
      title: "Test DELETE"
    }
  end
end
