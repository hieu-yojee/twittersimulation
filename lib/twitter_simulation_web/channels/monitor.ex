defmodule TwitterSimulationWeb.Monitor do
  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def tweet(tweet_msg) do
    Agent.get_and_update(__MODULE__, fn state -> tweet(state, tweet_msg) end)
  end

  def retweet(tweet_id) do
    Agent.get_and_update(__MODULE__, fn state -> retweet(state, tweet_id) end)
  end

  def get_top_tweets(num) do
    Agent.get(__MODULE__, fn state -> get_top_tweets(state[:tweet_logs], num) end)
  end

  defp get_top_tweets(nil, _) do
  end

  defp get_top_tweets(tweet_logs, num) do
    tweet_logs
    |> Enum.map(fn {id, tweet_log_val} -> {id, tweet_log_val[:tweet_msg], tweet_log_val[:retweet_num]} end)
    |> Enum.sort_by(fn {_, _, retweet_num} -> retweet_num end, &>=/2)
    |> Enum.take(num)
  end

  defp tweet(%{counter: counter, tweet_logs: tweet_logs}, tweet_msg) do
    new_counter = counter + 1
    tweet_log_val = %{tweet_msg: tweet_msg, retweet_num: 0}
    new_tweet_logs = Map.put(tweet_logs, new_counter, tweet_log_val)

    {{new_counter, tweet_log_val}, %{counter: new_counter, tweet_logs: new_tweet_logs}}
  end

  defp tweet(_state, tweet_msg) do
    tweet_log_val = %{tweet_msg: tweet_msg, retweet_num: 0}
    first_tweet_logs = %{0 => tweet_log_val}
    {{0, tweet_log_val}, %{counter: 0, tweet_logs: first_tweet_logs}}
  end

  defp retweet(state, tweet_id) do
    update_in(state, [:tweet_logs, tweet_id, :retweet_num], &(&1 + 1))
    |> tweet(state[:tweet_logs][tweet_id][:tweet_msg])
  end
end
