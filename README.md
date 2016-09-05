# Phoenix Api Docs

`PhoenixApiDocs` is a library written in the `Elixir` for the [Phoenix framework](http://www.phoenixframework.org/). It lets you generate API documentation in the [API Blueprint](https://apiblueprint.org/) format from annotations in controllers and automated tests.


## Installation

Add PhoenixApiDocs to your mix.exs dependencies:

```elixir
defp deps do
  [{:phoenix_api_docs, "~> 0.1.0"}]
end
```

Run `mix deps.get` to fetch the dependencies:

```
$ mix deps.get
```

In your `test/test_helper.exs` start gen server `PhoenixApiDocs.start` for logging requests and configure `ExUnit` to use `PhoenixApiDocs.Formatter`:

```elixir
PhoenixApiDocs.start
ExUnit.start(formatters: [ExUnit.CLIFormatter, PhoenixApiDocs.Formatter])
```


## Usage

Add `api_docs_info` to your `mix.exs`:

```elixir
def api_docs_info do
  [
    host: "https://api.acme.com",
    title: "ACME API",
    description: "API requires authorization. All requests must have valid `auth_token`"
  ]
end
```

Options:
* `host`: API host.
* `title`: Documentation title (can use Blueprint format).
* `description`: Documentation description (can use Blueprint format).

Add `PhoenixApiDocs.Controller` to your `phoenix` controller and use `api\3` macro to generate specification for the controller action:

```elixir
defmodule App.CommentController do
  use App.Web, :controller
  use PhoenixApiDocs.Controller

  api :GET, "/posts/:post_id/comments" do
    group "Comment" # If not provided, it will be guessed from the controller name (resource name)
    title "List comments for specific docs"
    description "Optiona description that will be displayed in the documentation"
    note "Optional note that will be displayed in the documentation"
    parameter :post_id, :integer, :required, "Post ID or slug"
  end
  def index(conn, %{"post_id" => post_id}) do
    ...
  end

  api :PUT, "/posts/:post_id/comments" do
    title "Update comment"
    parameter :post_id, :integer, :required, "Post ID or slug"
  end
  def update(conn, %{"comment" => comment_params}) do
    ...
  end

end
```

API specification options:

* `method`: HTTP method - GET, POST, PUT, PATCH, DELETE
* `url`: URL route from `phoenix router``
* `group`: Documentation routes are grouped by a group name (defaults to resource name guessed from the controller name)
* `title`: Title (can use Blueprint format)
* `description`: Description (optional, can use Blueprint format)
* `note`: Note (optional, can use Blueprint format)
* `parameter`: `name, type, required/optional, description`
  * required - `parameter :post_id, :integer, :required, "Post ID"`
  * optional - `parameter :post_id, :integer, "Post ID"`


In your tests select what requests and responses you want to include in the documentation by saving `conn` to `PhoenixApiDocs.ConnLogger`:

```elixir
  test "list comments for post", %{conn: conn} do
    post = insert(:post)
    insert_list(5, :comment, post: post)

    conn = get(
      conn,
      comments_path(conn, :index, post)
    )

    assert json_response(conn, 200)

    PhoenixApiDocs.ConnLogger.save(conn)
  end
```

`PhoenixApiDocs.ConnLogger.save` can be also piped:

```elixir
    conn = get(
      conn,
      comments_path(conn, :index, post)
    ) |> PhoenixApiDocs.ConnLogger.save
  end
```

After you run your tests, documentation in an API Blueprint format will be generate in a file `api.apib`

```
$ mix test
```

To generate the documentation in a HTML format use [Aglio renderer](https://github.com/danielgtaylor/aglio)

```
$ npm install aglio -g

$ mix phoenix.api_docs
```


## Configuration

The configuration options can be setup in `config.exs`:

```elixir
config :phoenix_api_docs,
  docs_path: "priv/static/docs",
  theme: "triple"
```

Config options:
* `docs_path`: Specify the path where the documentation will be generated. If you want to serve the documentation directly from the `phoenix` you can specify `priv/static/docs`.
* `theme`: HTML theme is generated using the [Aglio renderer](https://github.com/danielgtaylor/aglio).


## Common problems

#### Route is not generated after adding api annotation in the controller

Please make sure that the route you are using in the annotation matches exactly the route from the `phoenix router` (including params). Run `mix phoenix.routes` and compare the routes.

## Tasks to do

* `raise error` when route that is used in the annotation is not available in the `phoenix router`
