defmodule Pappap.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PappapWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Pappap.PubSub},
      # Start the Endpoint (http/https)
      PappapWeb.Endpoint,
      # Start a worker by calling: Pappap.Worker.start_link(arg)
      #Supervisor.child_spec({Task, fn -> Pappap.connect() end}, id: :connector),
      PappapWeb.Presence,
      # os情報辞書
      {Task, fn -> UAInspector.Downloader.download() end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    :ets.new(:match_result, [:public, :named_table])
    :ets.insert(:match_result, {"last_match", -1})
    opts = [strategy: :one_for_one, name: Pappap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PappapWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
