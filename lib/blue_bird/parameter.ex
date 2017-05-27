defmodule BlueBird.Parameter do
  @moduledoc """
  Defines the `Parameter` struct.
  """
  defstruct [
    :name,
    :type,
    :description,
    :additional_description,
    :default,
    :example,
    :required,
    :members
  ]

  @typedoc """
  Type that represents the Parameter struct.

    - `name`: The name as it appears in the url, e.g. `"id"` for the path
      `/users/:id`.
    - `type`: For example `"string"`, `"boolean"`, `"number"` etc. You can also
      set it to `"enum[<type>]"` (replace `<type>` with the actual type).
    - `members` (optional): List of possible values for the enum type.
    - `description` (optional): A description of the parameter.
    - `additional_description` (optional): Even more room for descriptions.
    - `default` (optional): The default value for this parameter.
    - `example` (optional): An example value for the parameter.
    - `required` (optional): Can be `true` or `false`. Will display `required`
      or `optional`. Will not display anything if not set.
  """
  @type t :: %BlueBird.Parameter{
    name: String.t,
    type: String.t,
    members: [String.t] | nil,
    description: String.t | nil,
    additional_description: String.t | nil,
    default: String.t | nil,
    example: String.t | nil,
    required: boolean | nil,
  }
end
