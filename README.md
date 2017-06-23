# BlueBird

[![Build Status](https://travis-ci.org/rhazdon/blue_bird.svg?branch=master)](https://travis-ci.org/rhazdon/blue_bird)
[![Hex.pm](https://img.shields.io/hexpm/v/blue_bird.svg)](https://hex.pm/packages/blue_bird)
[![Coverage Status](https://coveralls.io/repos/github/rhazdon/blue_bird/badge.svg?branch=master)](https://coveralls.io/github/rhazdon/blue_bird?branch=master)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rhazdon/blue_bird/blob/master/LICENSE)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/rhazdon/blue_bird.svg)](https://beta.hexfaktor.org/github/rhazdon/blue_bird)

`BlueBird` is a library written in the `Elixir` programming language for the [Phoenix framework](http://www.phoenixframework.org/).
It lets you generate API documentation in the [API Blueprint](https://apiblueprint.org/) format from annotations in controllers and automated tests.

## Installation

1. Add BlueBird to your mix.exs dependencies:

``` elixir
defp deps do
  [{:blue_bird, "~> 0.3.2"}]
end
```

2. Run `mix deps.get` to fetch the dependencies:

```
$ mix deps.get
```

3. In `test/test_helper.exs`, start the BlueBird logger with `BlueBird.start()`
and configure the results formatter as follows:

``` elixir
BlueBird.start()
ExUnit.start(formatters: [ExUnit.CLIFormatter, BlueBird.Formatter])
```

4. Add the following lines to `config.exs`:

``` elixir
config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: MyApp.Web.Router
```

5. Add `blue_bird_info` to your `mix.exs` to improve the generated docs:

``` elixir
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

``` elixir
def controller do
  quote do
    ...
    use BlueBird.Controller
    ...
  end
end
```

7. Install aglio:

``` bash
$ npm install aglio -g
```

## Usage

### Controller

Use the `api\3` macro to generate the specification for the controller action.

``` elixir
defmodule App.CommentController do
  use App.Web, :controller

  api :GET, "/posts/:post_id/comments" do
    title "List comments"
    description "Optional description"
    note "Optional note"
    warn "Optional warning"
    parameter :post_id, :integer, [description: "Post ID or slug"]
  end
  def index(conn, %{"post_id" => post_id}) do
    ...
  end
end
```

Optionally use the `apigroup` macro to set the resource group name and
description.

``` elixir
defmodule App.CommentController do
  use App.Web, :controller

  apigroup "Blog Comments", "some description"
  ...
end
```

### Router

Currently, BlueBird expects that the routes are piped through `:api`.

``` elixir
defmodule TestRouter do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller

  pipeline :api do
    ...
  end

  pipeline :foo do
    ...
  end

  scope "/" do
    pipe_through :api
    get "/get", TestController, :get  # This will work
  end

  scope "/" do
    pipe_through [:api, :foo]
    get "/get", TestController, :get  # This will work
  end

  scope "/" do
    pipe_through :foo
    get "/get", TestController, :get  # This will not work
  end
end
```

### Tests

In your tests, select which requests and responses you want to include in the
documentation by saving `conn` to `BlueBird.ConnLogger`:

``` elixir
test "list comments for post", %{conn: conn} do
  insert_posts_with_comments()

  conn = conn
  |> get(comments_path(conn, :index)
  |> BlueBird.ConnLogger.save()

  assert json_response(conn, 200)
end
```

After you run your tests, documentation will be written to `api.apib` in the
[API Blueprint](https://apiblueprint.org) format.

```
$ mix test
```

To generate an HTML documentation, use the convenience wrapper to the
[Aglio renderer](https://github.com/danielgtaylor/aglio).

```
$ mix bird.gen.docs
```

## Configuration

### `config.exs`:

The configuration options can be setup in `config.exs`:

```elixir
config :blue_bird,
  docs_path: "priv/static/docs",
  theme: "triple",
  router: YourApp.Web.Router,
  pipelines: [:api],
  ignore_headers: ["not-wanted"]
```

#### Options

* `docs_path`: Specify the path where the documentation will be generated. If
  you want to serve the documentation directly from the `phoenix`, you can
  specify `priv/static/docs`.
* `theme`: HTML theme is generated using the
  [Aglio renderer](https://github.com/danielgtaylor/aglio).
* `router`: Router of your application, in Phoenix 1.3 it will be
  YourAppName.Web.Router.
* `ignore_headers` (optional): If you want certain headers to be hidden from the
  documentation, you can add a list of header keys here. This can be helpful
  if you serve your application behind a proxy.
* `pipelines` (optional): Only routes that use the specified router pipelines
  will be included in the documentation. Defaults to `[:api]` if not set.

### `blue_bird_info()`:

**Options**:

* `host`: API host.
* `title`: Documentation title (can use Blueprint format).
* `description`: Documentation description (can use Blueprint format).
* `terms_of_service` (optional): Terms of service, string.
* `contact` (optional)
  * `name` (optional)
  * `url` (optional)
  * `email` (optional)
* `license` (optional)
  * `name` (optional)
  * `url` (optional)

## FAQ

### Route is not generated after adding API annotations to the controller

Please make sure that the route you are using in the annotation matches the
route from the `phoenix router` (including params) exactly. Run
`mix phoenix.routes` (or `mix phx.routes` if Phoenix >= 1.3) and compare the
routes.

Also note that only routes that use the api pipeline will be added to the
documentation.

### Body Parameter are not rendered

BlueBird reads the `body_params` from `%Plug.Conn{}`. These map is only set if
`body_params` is a binary.

#### Example

``` elixir
post build_conn(), "/", Poison.encode! %{my: data}  # recommended
post build_conn(), "/", "my=data"
```
