defmodule GrowUnits.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: GrowUnits.Endpoint,
        options: [port: 4001]
      )
    ]
    opts = [strategy: :one_for_one, name: GrowUnits.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
end
