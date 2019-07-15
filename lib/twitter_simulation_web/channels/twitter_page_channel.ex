defmodule TwitterSimulationWeb.TwitterPageChannel do
  use TwitterSimulationWeb, :channel
  alias TwitterSimulationWeb.IdGenerator
  alias TwitterSimulationWeb.TopTweetContainer

  def join("twitter_page:lobby", _payload, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_in("tweet", payload, socket) do
    id = IdGenerator.tweet(payload["body"])
    broadcast(socket, "tweet", %{id: id, msg: payload["body"]})

    {:noreply, socket}
  end

  def handle_in("retweet", payload, socket) do
    new_id = IdGenerator.retweet(String.to_integer(payload["id"]))
    broadcast(socket, "tweet", %{id: new_id, msg: payload["body"]})

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    top_tweets = TopTweetContainer.get_top_tweets()
    push(socket, "twitter:joined", %{msg: build_msg(top_tweets)})

    {:noreply, socket}
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
