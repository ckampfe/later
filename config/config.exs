# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :later,
  ecto_repos: [Later.Repo]

# Configures the endpoint
config :later, LaterWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "V3NdOSYWJ7V/Nj3XuNsBZev8ixkl+K4tSlrg0ueMlAgBWOqiZs8X7VtjT69pLxUh",
  render_errors: [view: LaterWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Later.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :later, Later.Storage, storage_module: Later.FileStorage

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
