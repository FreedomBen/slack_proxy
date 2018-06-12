defmodule SlackProxyWeb.Router do
  use SlackProxyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :verify_token
  end

  scope "/", SlackProxyWeb do
    pipe_through :api

    post "/buildcomplete", SlackController, :build_complete
    post "/deploycomplete", SlackController, :deploy_complete
  end

  defp secret_token_matches?(token) do
    token == elem(Confex.fetch_env(:slack_proxy, SlackProxyWeb.Endpoint), 1)[:secret_token]
  end

  defp verify_token(conn, _args) do
    if secret_token_matches?(conn.body_params["token"]) do
      conn
    else
      conn
      |> put_status(403)
      |> send_resp(403, "Unauthorized")
      |> halt()
    end
  end
end
