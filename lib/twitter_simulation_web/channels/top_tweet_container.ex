defmodule TwitterSimulationWeb.TopTweetContainer do
  def start_link(initial_state) do
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def retweet(retweet_log) do
    Agent.cast(__MODULE__, &retweet(&1, retweet_log))
  end

  def get_top_tweets() do
    Agent.get(__MODULE__, &(&1))
  end

  defp retweet(state = [{_, _, top_num}|_], retweet_log = {_, _, retweet_num}) when  top_num < retweet_num do
    insert(retweet_log, state, [])
    |> List.delete_at(0)
  end

  defp retweet(state, _retweet_log) do
    state
  end

  defp insert(x, [], result), do: result ++ [x]

  defp insert(x = {id, _, _}, [{id, _, _} | []], result) do
    [x | result] ++ [x]
  end

  defp insert(x = {id, _, _}, [{id, _, _} | tail ], result) do
    insert(x, tail, [x | result])
  end

  defp insert(x, [head | tail], result) do
    {_, _, retweet_num} = x
    {_, _, top_num} = head

    if retweet_num > top_num do
      insert(x, tail, result ++ [head])
    else
      result ++ [x | [head | tail]]
    end
  end

  # defp get_top_tweets(state) do
  #   state
  #   |> Enum.sort_by(fn {_, _, retweet_num} -> retweet_num end, &>=/2)
  #   |> Enum.take(10)
  # end
end
