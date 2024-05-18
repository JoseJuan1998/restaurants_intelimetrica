defmodule Restaurants.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RestaurantsWeb.Telemetry,
      Restaurants.Repo,
      {DNSCluster, query: Application.get_env(:restaurants, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Restaurants.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Restaurants.Finch},
      # Start a worker by calling: Restaurants.Worker.start_link(arg)
      # {Restaurants.Worker, arg},
      # Start to serve requests, typically the last entry
      RestaurantsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Restaurants.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RestaurantsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
