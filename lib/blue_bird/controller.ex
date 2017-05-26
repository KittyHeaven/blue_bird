defmodule BlueBird.Controller do
  @moduledoc """
  Defines the `api/3` macro used to add documentation to api routes.

  ## Usage

  Use `api/3` in your controllers.

      defmodule MyApp.Web.UserController do
        use BlueBird.Controller
        alias MyApp.Accounts

        api :GET, "users" do
          group "Posts"
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
      import BlueBird.Controller, only: [api: 3]
    end
  end

  @doc """
  Generates the description of a route.

  - `method`: HTTP method (GET, POST, PUT etc.)
  - `url`: Route as defined in the Phoenix router
  - `group`: Resource group. Defaults to resource name guessed from controller
  name.
  - `resource`: Title for the resource. Defaults to the url.
  - `title`: Title for the action
  - `description`: Description of the route
  - `note`: Note
  - `warning`: Warning
  - `parameter`: `name, type, description (optional)`

  ## Example

      api :GET, "user/:id/posts/:pid" do
        group "Posts"
        resource "Single Post"
        title "Show post"
        description "Show post by ID"
        note "You should really know this."
        warning "Please don't ever do this."
        parameter :id, :integer, "Post ID"
        parameter :name, :string
      end
  """
  defmacro api(method, path, do: block) do
    method_str    = method_to_string(method)
    metadata      = extract_metadata(block)
    group         = extract_option(metadata, :group)
    resource      = extract_option(metadata, :resource)
    title         = extract_option(metadata, :title)
    description   = extract_option(metadata, :description)
    note          = extract_option(metadata, :note)
    warning       = extract_option(metadata, :warning)
    parameters    = extract_parameters(metadata)

    quote do
      @spec api_doc(String.t, String.t) :: Route.t
      def api_doc(unquote(method_str), unquote(path)) do
        %Route{
          group:        unquote(group),
          resource:     unquote(resource),
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
    |> Enum.reduce([], fn(param, list) -> [param_to_map(param) | list] end)
    |> Enum.reverse
  end

  @spec param_to_map([String.t | atom | nil]) :: Parameter.t
  defp param_to_map([name, type, description]) do
    %Parameter{
      name: to_string(name),
      type: to_string(type),
      description: description
    }
  end
  defp param_to_map([name, type]) do
    %Parameter{
      name: to_string(name),
      type: to_string(type),
      description: nil
    }
  end
  defp param_to_map(_) do
    raise ArgumentError,
          """
          Wrong number of arguments for parameter option.
          Expected either two or three arguments. Correct usage:

              parameter :name, :type

              or

              parameter :name, :type, "description"
          """
  end
end
