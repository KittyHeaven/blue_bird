defmodule BlueBird.Test.Support.RouterUndocumented do
  @moduledoc """
  `BlueBird.Test.Support.Router` simulates a Phoenix Framework router.
  """
  use Phoenix.Router
  import Phoenix.Controller

  pipeline :api do
    plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json],
                       pass:  ["*/*"],
                       json_decoder: Poison
    plug :accepts, ["json"]
  end

  pipeline :another_api do
    plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json],
                       pass:  ["*/*"],
                       json_decoder: Poison
    plug :accepts, ["json"]
  end

  pipeline :not_configured do
    plug :accepts, ["html"]
  end

  scope "/", BlueBird.Test.Support do
    pipe_through :api

    get     "/waldorf",         ControllerUndocumented, :catchall
    post    "/waldorf",         ControllerUndocumented, :catchall
    get     "/undocumented",    ControllerUndocumented, :catchall
  end

  scope "/", BlueBird.Test.Support do
    pipe_through :another_api

    get     "/statler",         ControllerUndocumented, :catchall
    post    "/statler/:id",     ControllerUndocumented, :catchall
  end

  scope "/", BlueBird.Test.Support do
    pipe_through :not_configured

    get     "/fozzie",          ControllerUndocumented, :catchall
  end
end
