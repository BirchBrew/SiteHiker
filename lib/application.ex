require Logger

defmodule SiteHiker.Application do
  use Application

  def start(_type, _args) do
    port = (System.get_env("PORT") || "4000") |> String.to_integer()

    # List all child processes to be supervised
    children = [
      # Define workers and child supervisors to be supervised
      Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Router, options: [port: port]),
      Data.AlexaSiteInfo,
      Data.SiteDescription,
      Data.Favicon
    ]

    Logger.info("Router listening at http://localhost:#{port}")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SiteHiker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
