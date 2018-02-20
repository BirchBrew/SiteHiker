defmodule BlueHarvest.Application do
  use Application

  @port 9000

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Define workers and child supervisors to be supervised
      Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Web.Router, options: [port: @port])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BlueHarvest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
