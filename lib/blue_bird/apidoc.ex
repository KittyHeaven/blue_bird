defmodule BlueBird.ApiDoc do
  @moduledoc """
  Defines the `ApiDoc` struct.
  """
  defstruct [
    title: "",
    description: "",
    terms_of_service: "",
    host: "",
    routes: []
  ]

  @typedoc """
  Type that represents the ApiDoc struct.
  """
  @type t :: %BlueBird.ApiDoc{
    title: String.t,
    description: String.t,
    terms_of_service: String.t,
    host: String.t,
    routes: [BlueBird.Route.t]
  }
end
