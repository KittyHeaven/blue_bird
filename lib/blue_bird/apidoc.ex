defmodule BlueBird.ApiDoc do
  @moduledoc """
  Defines the `ApiDoc` struct.
  """
  defstruct [
    title: "",
    description: "",
    host: "",
    routes: []
  ]

  @typedoc """
  Type that represents the ApiDoc struct.
  """
  @type t :: %BlueBird.ApiDoc{
    title: String.t,
    description: String.t,
    host: String.t,
    routes: [BlueBird.Route.t]
  }
end
