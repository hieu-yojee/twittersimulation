defmodule TwitterSimulationWeb.Monitor do
  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def get_top_tweets() do
    Agent.get(__MODULE__, fn state -> get_top_tweets(state[:tweets]) end)
  end

  def tweet(tweet) do
    Agent.get_and_update(__MODULE__, fn state -> tweet(state, tweet) end)
  end

  def retweet(retweet) do
    Agent.get_and_update(__MODULE__, fn state -> retweet(state, retweet) end)
  end

  defp get_top_tweets(nil) do
  end

  defp get_top_tweets(tweets) do
    tweets
    |> Enum.map(fn {key, value} -> {key, value[:tweet], value[:retweet]} end)
    |> Enum.sort_by(fn {_, _, retweet} -> retweet end, &>=/2)
    |> Enum.take(2)
  end

  defp tweet(%{counter: counter, tweets: tweets}, tweet) do
    new_counter = counter + 1
    new_tweet = %{tweet: tweet, retweet: 0}
    new_tweets = Map.put(tweets, new_counter, new_tweet)

    {{new_counter, new_tweet}, %{counter: new_counter, tweets: new_tweets}}
  end

  defp tweet(state, tweet) do
    new_tweet = %{tweet: tweet, retweet: 0}
    {{0, new_tweet}, %{counter: 0, tweets: %{0 => new_tweet}}}
  end

  defp retweet(state, retweet) do
    new_state = update_in(state, [:tweets, String.to_integer(retweet), :retweet], &(&1 + 1))
    tweet(new_state, state[:tweets][String.to_integer(retweet)][:tweet])
  end
end
