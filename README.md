# BlueBird

[![Build Status](https://travis-ci.org/KittyHeaven/blue_bird.svg?branch=master)](https://travis-ci.org/KittyHeaven/blue_bird)
[![Hex.pm](https://img.shields.io/hexpm/v/blue_bird.svg)](https://hex.pm/packages/blue_bird)
[![Coverage Status](https://coveralls.io/repos/github/KittyHeaven/blue_bird/badge.svg?branch=master)](https://coveralls.io/github/KittyHeaven/blue_bird?branch=master)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rhazdon/blue_bird/blob/master/LICENSE)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/KittyHeaven/blue_bird.svg)](https://beta.hexfaktor.org/github/KittyHeaven/blue_bird)

`BlueBird` is an api documentation builder for the [Phoenix framework](http://www.phoenixframework.org/). The documentation is generated in the
[API Blueprint](https://apiblueprint.org/) format from annotations in
your controllers and from automated tests.

## Installation

1. Add BlueBird to your mix.exs dependencies:

```elixir
defp deps do
  [{:blue_bird, "~> 0.4.0"}]
end
```

2. Run `mix deps.get` to fetch the dependencies:

```bash
$ mix deps.get
```

3. In `test/test_helper.exs`, start the BlueBird logger with `BlueBird.start()`
   and configure ExUnit as follows:

```elixir
BlueBird.start()
ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])
```

4. Add the following lines to `config.exs`:

```elixir
config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: AppWeb.Router
```

5. Add `blue_bird_info` to your `mix.exs` to add global information:

```elixir
def blue_bird_info do
  [
    host: "https://api.acme.com",
    title: "ACME API",
    description: """
                 API requires authorization. All requests must have valid
                 `auth_token`.
                 """
  ]
end
```

6. Add `BlueBird.Controller` to your `web.ex` controller function:

```elixir
def controller do
  quote do
    ...
    use BlueBird.Controller
    ...
  end
end
```

7. Install aglio:

```bash
$ npm install aglio -g
```

## Usage

### Router

By default, documentation is only generated for routes that use the `:api`
pipeline. You can configure which pipelines to use in the configuration.

```elixir
config :blue_bird,
  pipelines: [:something_else]
```

### Controller

Use the `api/3` macro to annotate your controller functions.

```elixir
defmodule AppWeb.CommentController do
  use AppWeb, :controller

  api :GET, "/posts/:post_id/comments" do
    title "List comments"
    description "Optional description"
    note "Optional note"
    warning "Optional warning"
    parameter :post_id, :integer, [description: "Post ID or slug"]
  end
  def index(conn, %{"post_id" => post_id}) do
    ...
  end
end
```

BlueBird groups routes by controller. By default, it uses the controller names
as group names in the headings. You can change the group name of a controller
by adding the `apigroup` macro to your controller modules. The macro can also
be used to add a group description.

```elixir
defmodule AppWeb.CommentController do
  use AppWeb, :controller

  apigroup "Blog Comments", "some description"
  ...
end
```

### Tests

In your tests, select which requests and responses you want to include in the
documentation by saving `conn` to `BlueBird.ConnLogger`:

```elixir
test "list comments for post", %{conn: conn} do
  insert_posts_with_comments()

  conn = conn
  |> get(comments_path(conn, :index)
  |> BlueBird.ConnLogger.save()

  assert json_response(conn, 200)
end
```

## Generating the documentation

First, run your tests:

```bash
$ mix test
```

All `conn`s that were saved to the `ConnLogger` will be processed. The
documentation will be written to the file `api.apib` in the directory specified
in the configuration. The file uses the [API Blueprint](https://apiblueprint.org) format.

There are [several tools](https://apiblueprint.org/tools.html#renderers) that
can render `apib` files to html. `BlueBird` has a mix task which uses
[Aglio renderer](https://github.com/danielgtaylor/aglio) to generate an html
document from the generated `apib` file.

```
$ mix bird.gen.docs
```

If you use BlueBird in an umbrella app, you must run the command from within
the folder of the child app (e.g. `apps/myapp_web`).

## Configuration

### `config.exs`

The configuration options can be setup in `config.exs`:

```elixir
config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: YourAppWeb.Router,
  pipelines: [:api],
  ignore_headers: ["not-wanted"]
```

If you wish to have separate configuration options for apps in an Umbrella project,
you can specify per-app settings as follow in the app specific `config.exs`:

```elixir
config :my_app, :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: YourAppWeb.Router,
  pipelines: [:api],
  ignore_headers: ["not-wanted"]
```

#### Options

- `docs_path`: Specify the path where the documentation will be generated. If
  you want to serve the documentation directly from the `phoenix` app, you can
  specify `priv/static/docs`. If you use BlueBird within an umbrella app, the
  path is relative to the root folder of the umbrella app.
- `theme`: The [Aglio](https://github.com/danielgtaylor/aglio) theme to be used
  for the html documentation.
- `router`: The router module of your application.
- `pipelines` (optional): Only routes that use the specified router pipelines
  will be included in the documentation. Defaults to `[:api]` if not set.
- `ignore_headers` (optional): You can hide certain headers from the
  documentation with this option. This can be helpful if you serve your
  application behind a proxy. If the value is a list of strings as above, the
  specified headers will be hidden from both requests and responses. If you
  want to hide different headers from requests and responses, you can use a map
  instead: `ignore_headers: %{request: ["ignore-me"], response: ["and-me"]}`.
- `trim_path` (optional): Allows you to remove a path prefix from the docs. For
  example, if all your routes start with `/api` and you don't want to display
  this prefix in the documentation, set `trim_path` to `"/api"`.

### `blue_bird_info()`

#### Options

- `host`: API host.
- `title`: Documentation title (can use Blueprint format).
- `description`: Documentation description (can use Blueprint format).
- `terms_of_service` (optional): Terms of service, string.
- `contact` (optional)
  - `name` (optional)
  - `url` (optional)
  - `email` (optional)
- `license` (optional)
  - `name` (optional)
  - `url` (optional)

## FAQ

### Route is not generated after adding API annotations to the controller

Please make sure that the route you are using in the annotation matches the
route from the `phoenix router` (including params) exactly. Run
`mix phoenix.routes` (or `mix phx.routes` if Phoenix >= 1.3) and compare the
routes.

Also note that only routes that use the api pipeline (or the pipelines you
configured in config.exs) will be added to the documentation.

### Body Parameters are not rendered

BlueBird reads the `body_params` from `%Plug.Conn{}`. This map is only set if
`body_params` is a binary.

#### Example

```elixir
post build_conn(), "/", Poison.encode! %{my: data}  # recommended
post build_conn(), "/", "my=data"
```
