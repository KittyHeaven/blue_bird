defmodule BlueBird.Test.Support.Controller do
  @moduledoc """
  `BlueBird.Test.Support.Controller` simulates a Phoenix Framework controller.
  """
  use BlueBird.Controller
  use Phoenix.Controller

  @json_response Poison.encode!(%{status: "ok"})

  api :GET, "/waldorf" do
    title "Get Waldorf"
  end

  api :POST, "/waldorf" do
    title "Post Waldorf"
  end

  api :GET, "/statler" do
    title "Get Statler"
    description "Description"
    note "Note"
    warning "Warning"
  end

  api :POST, "/statler/:id" do
    title "Post Statler"
    parameter :id, :int, [description: "ID"]
  end

  def catchall(conn, params) do
    body = Map.get(params, "body", @json_response)
    status = Map.get(params, "status", 200)
    conn = conn |> put_resp_header("ignore-me", "whatever")

    send_resp(conn, status, body)
  end
end
