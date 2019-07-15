defmodule TwitterSimulationWeb.IdGenerator do
  alias TwitterSimulationWeb.TweetContainer

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def tweet(tweet_msg) do
    Agent.get_and_update(__MODULE__, &tweet(&1, tweet_msg))
  end

  def retweet(tweet_id) do
    Agent.get_and_update(__MODULE__, &retweet(&1, tweet_id))
  end

  defp tweet(state, tweet_msg) do
    new_state = state + 1
    TweetContainer.tweet({new_state, tweet_msg})

    {new_state, new_state}
  end

  defp retweet(state, tweet_id) do
    new_state = state + 1
    TweetContainer.retweet({new_state, tweet_id})

    {new_state, new_state}
  end
end
