defmodule BlueBird.Route do
  @moduledoc """
  Defines the `Route` struct.
  """
  defstruct [
    :group,
    :resource,
    :title,
    :description,
    :note,
    :warning,
    method: "",
    path: "",
    parameters: [],
    requests: []
  ]

  @typedoc """
  Type that represents the Route struct.
  """
  @type t :: %BlueBird.Route{
          method: String.t(),
          path: String.t(),
          group: String.t() | nil,
          resource: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          note: String.t() | nil,
          warning: String.t() | nil,
          parameters: [BlueBird.Parameter.t()],
          requests: [BlueBird.Request.t()]
        }
end
