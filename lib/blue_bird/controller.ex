defmodule BlueBird.Controller do
  @moduledoc """
  Defines macros used to add documentation to api routes.

  ## Usage

  Use `api/3` in your controllers. Optionally add the `apigroup/1` or
  `apigroup/2` macro to your controllers.

      defmodule MyApp.Web.UserController do
        use BlueBird.Controller
        alias MyApp.Accounts

        apigroup "Customers", "These are the routes that we'll talk about."

        api :GET, "users" do
          title "List users"
          description "Lists all active users"
        end
        def index(conn, _params) do
          users = Accounts.list_users()
          render(conn, "index.html", users: users)
        end
      end

  Instead of adding `use BlueBird.Controller` to every controller module, you
  can also add it to the `web.ex` controller function to make it available
  in every controller.

      def controller do
        quote do
          ...
          use BlueBird.Controller
          ...
        end
      end
  """
  alias BlueBird.{Parameter, Route}

  defmacro __using__(_) do
    quote do
      import BlueBird.Controller, only: [api: 3, apigroup: 1, apigroup: 2]
    end
  end

  @doc """
  Describes a route.

  ```
  api <method> <url> do ... end
  ```

  - `method`: HTTP method (GET, POST, PUT etc.)
  - `url`: Route as defined in the Phoenix router
  - `title` (optional): Title for the action
  - `description` (optional): Description of the route
  - `note` (optional): Note
  - `warning` (optional): Warning
  - `parameter` (optional): Used for path and query parameters. It takes the
    name as defined in the route and the type. The third parameter is an
    optional keyword list with additional options. See `BlueBird.Parameter`
    for descriptions of the available options.

  ## Example

      api :GET, "user/:id/posts/:slug" do
        title "Show post"
        description "Show post by user ID and post slug"
        note "You should really know this."
        warning "Please don't ever do this."
        parameter :id, :integer
        parameter :slug, :string, [
          description: "This is the post slug.",
          example: "whatever"
        ]
  """
  defmacro api(method, path, do: block) do
    method_str    = method_to_string(method)
    metadata      = extract_metadata(block)
    title         = extract_option(metadata, :title)
    description   = extract_option(metadata, :description)
    note          = extract_option(metadata, :note)
    warning       = extract_option(metadata, :warning)
    parameters    = extract_parameters(metadata)

    quote do
      @spec api_doc(String.t, String.t) :: Route.t
      def api_doc(unquote(method_str), unquote(path)) do
        %Route{
          title:        unquote(title),
          description:  unquote(description),
          note:         unquote(note),
          method:       unquote(method_str),
          warning:      unquote(warning),
          path:         unquote(path),
          parameters:   unquote(Macro.escape(parameters))
        }
      end
    end
  end

  @doc """
  Defines the name and an optional description for a resource group.

  BlueBird defines groups by the controller. By default, the group name
  is taken from the controller name. If you want to specify a different name,
  you can use this macro. You can also add a group description as a second
  parameter.

  ## Example

      apigroup "resource group name"

  or

      apigroup "resource group name", "description"
  """
  defmacro apigroup(name, description \\ "") do
    name = to_string(name)
    description = to_string(description)

    quote do
      @spec api_group :: %{name: String.t, description: String.t}
      def api_group do
        %{
          name: unquote(name),
          description: unquote(description)
        }
      end
    end
  end

  @spec method_to_string(String.t | atom) :: String.t
  defp method_to_string(method) when is_binary(method) or is_atom(method) do
    method
    |> to_string
    |> String.upcase
  end

  @spec extract_metadata(
    {:__block__, any, {String.t, any, [any]}} | {String.t, any, [any]} | nil) ::
    [{atom, any}]
  defp extract_metadata({:__block__, _, data}) do
    Enum.map(data, fn({name, _line, params}) ->
      {name, params}
    end)
  end
  defp extract_metadata({key, _, data}), do: [{key, data}]
  defp extract_metadata(nil), do: []

  @spec extract_option([{atom, any}], atom) :: nil | any
  defp extract_option(metadata, key) do
    values = metadata |> Keyword.get(key)

    cond do
      is_nil(values) -> nil
      length(values) == 1 -> List.first(values)
      true -> raise ArgumentError,
              "Expected single value for #{key}, got #{length(values)}"
    end
  end

  @spec extract_parameters([{atom, any}]) :: [Parameter.t]
  defp extract_parameters(metadata) do
    metadata
    |> Keyword.get_values(:parameter)
    |> Enum.map(fn
      [quoted] -> quoted |> Code.eval_quoted |> elem(0)
      param -> param
    end)
    |> Enum.reduce([], fn(param, list) -> [param_to_map(param) | list] end)
    |> Enum.reverse
  end

  @spec param_to_map([any]) :: Parameter.t
  defp param_to_map([name, type, options]) when is_list(options) do
    Map.merge(
      %Parameter{
        name: to_string(name),
        type: to_string(type)
      },
      Enum.into(options, %{})
    )
  end
  defp param_to_map([name, type]) do
    %Parameter{
      name: to_string(name),
      type: to_string(type)
    }
  end
  defp param_to_map([_, _, _]) do
    raise ArgumentError, "The parameter macro expects a keyword list as " <>
                         "third argument."
  end
  defp param_to_map(_) do
    raise ArgumentError,
          """
          Wrong number of arguments for parameter option.
          Expected either two or three arguments: The name, the type
          and an optional keyword list. Correct usage:

              parameter :name, :type

              or

              parameter :name, :type, [description: "description",
                                       optional: true]
          """
  end
end
