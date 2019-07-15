defmodule TwitterSimulationWeb.TwitterPageChannel do
  use TwitterSimulationWeb, :channel
  alias TwitterSimulationWeb.Monitor

  def join("twitter_page:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (twitter_page:lobby).
  def handle_in("tweet", payload, socket) do
    {id, tweet_log_val} = Monitor.tweet(payload["body"])

    broadcast(socket, "tweet", %{id: id, msg: tweet_log_val[:tweet_msg]})
    {:noreply, socket}
  end

  def handle_in("retweet", payload, socket) do
    {id, tweet_log_val} = Monitor.retweet(String.to_integer(payload["body"]))

    broadcast(socket, "tweet", %{id: id, msg: tweet_log_val[:tweet_msg]})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    top_tweets = Monitor.get_top_tweets(10)
    push(socket, "twitter:joined", %{msg: build_msg(top_tweets)})
    {:noreply, socket}
  end

  defp build_msg(nil) do
    "welcome"
  end

  defp build_msg(top_tweets) do
    Enum.map_join(
      top_tweets,
      " ",
      fn {id, tweet_msg, retweet_num} ->
        " [" <> Integer.to_string(id) <> ", " <> tweet_msg <> ", " <> Integer.to_string(retweet_num) <> "] " end
      )
  end
end
