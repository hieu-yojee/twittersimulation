defmodule TwitterSimulationWeb.TwitterPageChannel do
  use TwitterSimulationWeb, :channel

  def join("twitter_page:lobby", _payload, socket) do
    {:ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (twitter_page:lobby).
  def handle_in("tweet_all", payload, socket) do
    broadcast socket, "tweet_all", payload
    {:noreply, socket}
  end
end
