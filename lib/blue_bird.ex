defmodule BlueBird do
  @moduledoc false
  use Application

  import Supervisor.Spec

  def start(_type, []) do
    IO.puts "Starting BlueBird"

    children = [
      worker(BlueBird.ConnLogger, [])
    ]

    opts = [strategy: :one_for_one, name: BlueBird.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start(options \\ []) do
    Application.start(:blue_bird)

    Enum.each(options, fn {k, v} ->
      Application.put_env(:blue_bird, k, v)
    end)

    :ok
  end
end
