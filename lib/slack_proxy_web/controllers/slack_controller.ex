defmodule SlackProxyWeb.SlackController do
  use SlackProxyWeb, :controller

  @avatar ":graysquad:"
  @channel "gray"
  @username "Gray Team Build Bot"
  @slack_base_uri "https://slack.com/api/chat.postMessage"
  @efile_service_base_url "https://canopy.githost.io/java/efile-service"

  def build_complete(conn, params) do
    "Build  #{success_fail_msg(params)} - #{@efile_service_base_url}/merge_requests/#{params["mr_id"]}"
    |> slack_chat_postmessage(conn, params)
  end

  def deploy_complete(conn, params) do
    "Deploy to #{params["environment"]} #{success_fail_msg(params)}"
    |> slack_chat_postmessage(conn, params)
  end

  defp slack_chat_postmessage(header_text, conn, params) do
    header_text
    |> info_block(params)
    |> slack_request_body
    |> post_to_slack
    |> return_json(conn)
  end

  defp return_json(json, conn), do: json(conn, json)

  defp post_to_slack(body) do
    case HTTPoison.post(@slack_base_uri, body, [{"Content-Type", "application/x-www-form-urlencoded"}]) do
	  {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body

	  {:error, %HTTPoison.Error{reason: reason}} ->
        Map.merge(%{ok: false}, reason)
    end
  end

  defp slack_token do
    elem(Confex.fetch_env(:slack_proxy, SlackProxyWeb.Endpoint), 1)[:slack_token]
  end

  defp slack_request_body(text) do
    Enum.join([
      "token=#{slack_token()}",
      "channel=#{@channel}",

      "text=#{URI.encode(text)}",
      "username=#{URI.encode(@username)}",
      "icon_emoji=#{@avatar}"
    ], "&")
  end

  defp info_block(header, %{"abbrev" => "true"}), do: header

  defp info_block(header, params) do
    """
    #{header}
    ```
    Author:           #{params["author"]}
    Commit title:     #{params["title"]}
    Branch:           #{params["branch"]}
    Started by:       #{params["user"]}
    ```
    """
  end

  defp success_fail_msg(%{"failed" => "true"}), do: ":x:  *Failed!*"
  defp success_fail_msg(_params), do: ":heavy_check_mark:  Succeeded!"
end
