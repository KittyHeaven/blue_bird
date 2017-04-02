defmodule GeneratorTest do
  use ExUnit.Case
  use Plug.Test

  doctest BlueBird

  @opts TestRouter.init([])

  test "returns hello world" do
    # Create a test connection
    conn = conn(:get, "/get")
    |> put_req_header("accept", "application/json")
    |> put_req_header("accept-language", "de-de")

    # Invoke the plug
    conn = TestRouter.call(conn, @opts)

    # IO.puts "#{inspect conn}"

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    # assert conn.resp_body == "world"

    # IO.puts "================"
    # IO.puts "================"
    # IO.puts "================"
    # IO.puts "================"

    # a = TestRouter.__routes__()

    # IO.puts "#{inspect a}"

    # IO.puts "================"
    # IO.puts "================"
    # IO.puts "================"
    # IO.puts "================"

    BlueBird.Generator.generate_docs_for_routes(TestRouter, [conn, conn])

    abc = BlueBird.Generator.generate_blueprint_file(TestRouter, [conn])
    BlueBird.BlueprintWriter.run(abc)
  end

  # test "post" do
  #   # Create a test connection
  #   conn = conn(:post, "/post", %{p: 5}) |> put_req_header("content-type", "application/json")

  #   # Invoke the plug
  #   conn = TestRouter.call(conn, @opts)

  #   # IO.puts "================"
  #   # IO.puts "================"
  #   # IO.puts "#{inspect conn}"
  #   # IO.puts "================"
  #   # IO.puts "================"

  #   # Assert the response and status
  #   assert conn.state == :sent
  #   assert conn.status == 201

  #   BlueBird.Generator.generate_docs_for_routes(TestRouter, [conn])

  #   abc = BlueBird.Generator.generate_blueprint_file(TestRouter, [conn])
  #   BlueBird.BlueprintWriter.run(abc)
  # end
end
