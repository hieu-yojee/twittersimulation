defmodule TwitterSimulationWeb.TwitterPageChannel do
  use TwitterSimulationWeb, :channel
  alias TwitterSimulationWeb.Monitor

  def join("twitter_page:lobby", _payload, socket) do
    send(self, {:after_join})
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (twitter_page:lobby).
  def handle_in("tweet", payload, socket) do
    resp_tweet = Monitor.tweet(payload["body"])

    id = elem(resp_tweet, 0)
    msg = elem(resp_tweet, 1)


    broadcast(socket, "tweet", %{id: id, msg: msg[:tweet]})
    {:noreply, socket}
  end

  def handle_in("retweet", payload, socket) do
    resp_tweet = Monitor.retweet(payload["body"])

    id = elem(resp_tweet, 0)
    msg = elem(resp_tweet, 1)

    broadcast(socket, "tweet", %{id: id, msg: msg[:tweet]})
    {:noreply, socket}
  end

  def handle_info({:after_join}, socket) do
    top_tweets = Monitor.get_top_tweets()
    IO.inspect(top_tweets)
    # broadcast! socket, "user:joined", %{challenge_state: challenge_state(challenge.id)}



    aa = %{msg: build_msg(top_tweets)}
    |> IO.inspect()

    push(socket, "twitter:joined", aa)
    {:noreply, socket}
  end

  defp build_msg(nil) do
    "welcome"
  end

  defp build_msg(top_tweets) do
    Enum.map_join(
      top_tweets,
      "***",
      # fn {key, val} -> Integer.to_string(key) <> "-->" <> val[:tweet] end
      fn {key, tweet, retweet} -> Integer.to_string(key) <> "-->" <> tweet <> " -->" <> Integer.to_string(retweet) end

      )
  end
end
