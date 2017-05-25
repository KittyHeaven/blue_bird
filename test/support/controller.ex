defmodule BlueBird.Test.Support.TestController do
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
    group "Waldorf"
    title "Post Waldorf"
  end

  api :GET, "/statler" do
    group "Statler"
    resource "Statler Collection"
    title "Get Statler"
    description "Description"
    note "Note"
    warning "Warning"
  end

  api :POST, "/statler/:id" do
    group "Statler"
    resource "Single Statler"
    title "Post Statler"
    parameter :id, :int, "ID"
  end

  def catchall(conn, params) do
    body = Map.get(params, "body", @json_response)
    status = Map.get(params, "status", 200)

    send_resp(conn, status, body)
  end
end
