# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :slack_proxy, SlackProxyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Da/4lv0TwAmsjrXx6txlrYVBae+6i5QdNN4Wr6LWZ77hPDbdc24aiv2dW9ydNGCp",
  render_errors: [view: SlackProxyWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SlackProxy.PubSub,
           adapter: Phoenix.PubSub.PG2],
  port: {:system, "PORT", 4000},          # pull in at runtime with confex
  slack_token: {:system, "SLACK_TOKEN"},  # pull in at runtime with confex
  secret_token: {:system, "SECRET_TOKEN"} # pull in at runtime with confex

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
