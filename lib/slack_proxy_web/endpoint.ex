defmodule SlackProxyWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :slack_proxy

  socket "/socket", SlackProxyWeb.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :slack_proxy, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_slack_proxy_key",
    signing_salt: "efSXe670"

  plug SlackProxyWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    {:ok, config} = Confex.Resolver.resolve(config)

    unless config[:slack_token] do
      raise "SLACK_TOKEN must be set with valid token!"
    end

    unless config[:secret_token] do
      raise "SECRET_TOKEN must be set with valid token!"
    end

    config
    |> Keyword.put(:url, Keyword.merge(config[:url], Keyword.put(config[:url], :port, config[:port])))
    |> Keyword.put(:http, [:inet6, port: config[:port]])

    {:ok, config}
  end
end