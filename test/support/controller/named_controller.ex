defmodule BlueBird.Test.Support.NamedController do
  @moduledoc """
  `BlueBird.Test.Support.NamedController` simulates a Phoenix Framework controller.
  """
  use BlueBird.Controller
  use Phoenix.Controller

  @json_response Poison.encode!(%{status: "ok"})

  apigroup "Bobtails", "The Bobtail Resource"

  api :GET, "/astoria" do
    title "Get Astoria"
  end

  api :POST, "/astoria" do
    title "Post Astoria"
  end

  def catchall(conn, params) do
    body = Map.get(params, "body", @json_response)
    status = Map.get(params, "status", 200)

    send_resp(conn, status, body)
  end
end
