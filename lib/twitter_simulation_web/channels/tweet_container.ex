defmodule TwitterSimulationWeb.TweetContainer do
  use GenServer
  alias TwitterSimulationWeb.TopTweetContainer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :protected, write_concurrency: true])
    {:ok, nil}
  end

  def tweet(tweet_id_msg) do
    GenServer.cast(__MODULE__, {:tweet, tweet_id_msg})
  end

  def retweet(tweet_ids) do
    GenServer.cast(__MODULE__, {:retweet, tweet_ids})
  end

  def handle_cast({:tweet, tweet_id_msg}, state) do
    handle_tweet(state, tweet_id_msg)
    {:noreply, state}
  end

  def handle_cast({:retweet, tweet_ids}, state) do
    handle_retweet(state, tweet_ids)
    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:ok, state}
  end

  defp handle_tweet(_state, {id, tweet_msg}) do
    :ets.insert(__MODULE__, {id, {tweet_msg, 0}})
  end

  defp handle_retweet(state, {new_id, origin_id}) do
    case :ets.lookup(__MODULE__, origin_id) do
      [{^origin_id, {origin_msg, retweet_num}}] ->
        TopTweetContainer.retweet({origin_id, origin_msg, retweet_num + 1})
        :ets.insert(__MODULE__, {origin_id, {origin_msg, retweet_num + 1}})
        handle_tweet(state, {new_id, origin_msg})
      [] -> nil
    end
  end
end
