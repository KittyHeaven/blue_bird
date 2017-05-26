defmodule BlueBird.Route do
  @moduledoc """
  Defines the `Route` struct.
  """
  defstruct [
    :group,
    :title,
    :description,
    :note,
    :method,
    :warning,
    :path,
    :parameters,
    :requests
  ]

  @typedoc """
  Type that represents the Route struct.
  """
  @type t :: %BlueBird.Route{
    group: String.t | nil,
    title: String.t | nil,
    description: String.t | nil,
    note: String.t | nil,
    method: String.t,
    warning: String.t | nil,
    path: String.t,
    parameters: [BlueBird.Parameter.t],
    requests: [BlueBird.Request.t]
  }
end
