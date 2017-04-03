# Blue Bird

[![Build Status](https://travis-ci.org/rhazdon/blue_bird.svg?branch=master)](https://travis-ci.org/rhazdon/blue_bird)

`BlueBird` is a library written in the `Elixir` programming language for the [Phoenix framework](http://www.phoenixframework.org/).
It lets you generate API documentation in the [API Blueprint](https://apiblueprint.org/) format from annotations in controllers and automated tests.


## Installation


1. Add BlueBird to your mix.exs dependencies (directly from Github until released):
```elixir
defp deps do
  [{:blue_bird, github: "rhazdon/blue_bird"}]
end
```

2. Run `mix deps.get` to fetch the dependencies:
```
$ mix deps.get
```

3. In your `test/test_helper.exs` start the BlueBird logger via `BlueBird.start()` and configure the results formatter as follows:
```elixir
BlueBird.start()
ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])
```

4. Configre BlueBird by adding to `config.exs`:
```elixir
config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: YourApp.Web.Router
```

5. Add `blue_bird_info` to your `mix.exs` to improve the generated docs:
```elixir
def blue_bird_info do
  [
    host: "https://api.acme.com",
    title: "ACME API",
    description: "API requires authorization. All requests must have valid `auth_token`"
  ]
end
```

## Usage

Add `BlueBird.Controller` to your `web.ex` controller function:
```elixir
  def controller do
    quote do
      use BlueBird.Controller
  ...
```
Use `api\3` macro to generate the specification for the controller action:

```elixir
defmodule App.CommentController do
  use App.Web, :controller

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


In your tests select which requests and responses you want to include in the documentation by saving `conn` to `BlueBird.ConnLogger`:

```elixir
  test "list comments for post", %{conn: conn} do
    post = insert(:post)
    insert_list(5, :comment, post: post)

    conn = get(
      conn,
      comments_path(conn, :index, post)
    )

    assert json_response(conn, 200)

    BlueBird.ConnLogger.save(conn)
  end
```

`BlueBird.ConnLogger.save` can be also piped into:

```elixir
    conn = get(
      conn,
      comments_path(conn, :index, post)
    ) |> BlueBird.ConnLogger.save
  end
```

After you run your tests, documentation in the API Blueprint format will be saved to `api.apib`

```
$ mix test
```

To generate the documentation in a HTML format use the convenience wrapper tothe [Aglio renderer](https://github.com/danielgtaylor/aglio)

```
$ npm install aglio -g

$ mix bird.gen.docs
```


## Configuration

### `config.exs`:

The configuration options can be setup in `config.exs`:

```elixir
config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: YourApp.Web.Router
```

**Options**:

* `docs_path`: Specify the path where the documentation will be generated. If you want to serve the documentation directly from the `phoenix` you can specify `priv/static/docs`.
* `theme`: HTML theme is generated using the [Aglio renderer](https://github.com/danielgtaylor/aglio).
* `router`: Router of your application, in Phoenix 1.3 it will be YourAppName.Web.Router


### `blue_bird_info()`:

**Options**:

* `host`: API host.
* `title`: Documentation title (can use Blueprint format).
* `description`: Documentation description (can use Blueprint format).


## Common problems

#### Route is not generated after adding API annotations to the controller

Please make sure that the route you are using in the annotation matches the route from the `phoenix router` (including params) exactly. Run `mix phoenix.routes` (or `mix phx.routes` if Phoenix >= 1.3) and compare the routes.

## TODO:

- [ ] `raise error` when route that is used in the annotation is not available in the `phoenix router`
- [ ] Document that routes have to be part of the api pipeline for now
- [ ] Make the pipelines configurable
- [ ] Document `BlueBird.Controller`
- [ ] Document `BlueBird.BlueprintWriter`
- [ ] Document `Mix.Tasks.Bird.Gen.Docs`
