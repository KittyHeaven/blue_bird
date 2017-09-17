defmodule BlueBird.Test.Support.Router do
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

    get     "/waldorf",         TestController, :catchall
    post    "/waldorf",         TestController, :catchall
    get     "/undocumented",    TestController, :catchall
    get     "/astoria",         NamedController, :catchall
    post    "/astoria",         NamedController, :catchall
  end

  scope "/", BlueBird.Test.Support do
    pipe_through :another_api

    get     "/statler",         TestController, :catchall
    post    "/statler/:id",     TestController, :catchall
  end

  scope "/", BlueBird.Test.Support do
    pipe_through :not_configured

    get     "/fozzie",          TestController, :catchall
  end
end
