defmodule TwitterSimulationWeb.TweetContainer do
  alias TwitterSimulationWeb.TopTweetContainer

  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def tweet(tweet_id_msg) do
    Agent.cast(__MODULE__, &tweet(&1, tweet_id_msg))
  end

  def retweet(tweet_ids) do
    Agent.cast(__MODULE__, &retweet(&1, tweet_ids))
  end

  defp tweet(state, {id, tweet_msg}) do
    Map.put(state, id, {tweet_msg, 0})
  end

  defp retweet(state, {new_id, origin_id}) do
    {origin_msg, retweet_num} = Map.get(state, origin_id)
    new_retweet_num = retweet_num + 1
    TopTweetContainer.retweet({origin_id, origin_msg, new_retweet_num})

    Map.update!(state, origin_id, fn _ -> {origin_msg, new_retweet_num} end)
    |> tweet({new_id, origin_msg})
  end
end
