defmodule BlueBird.ApiDoc do
  @moduledoc """
  Defines the `ApiDoc` struct.
  """
  defstruct title: "",
            description: "",
            terms_of_service: "",
            host: "",
            contact: [
              name: "",
              url: "",
              email: ""
            ],
            license: [
              name: "",
              url: ""
            ],
            routes: [],
            groups: %{}

  @typedoc """
  Type that represents the ApiDoc struct.
  """
  @type t :: %BlueBird.ApiDoc{
          title: String.t(),
          description: String.t(),
          terms_of_service: String.t(),
          host: String.t(),
          contact: contact,
          license: license,
          routes: [BlueBird.Route.t()],
          groups: %{optional(String.t()) => String.t()}
        }

  @type contact :: [
          name: String.t(),
          url: String.t(),
          email: String.t()
        ]

  @type license :: [
          name: String.t(),
          url: String.t()
        ]
end
