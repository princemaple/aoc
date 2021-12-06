# Title: Day6

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule P1 do
  def calc(data, days) do
    data
    |> Enum.map(&calc_each(&1 + 1, days))
    |> Enum.sum()
  end

  def calc_each(n, days) when n > days, do: 1

  def calc_each(n, days) do
    calc_each(7, days - n) + calc_each(9, days - n)
  end
end

P1.calc(data, 80)

defmodule P2 do
  def calc(data, days, cache) do
    data
    |> Enum.map(&calc_each(&1 + 1, days, cache))
    |> Enum.sum()
  end

  def calc_each(n, days, _cache) when n > days, do: 1

  def calc_each(n, days, cache) do
    if got = Agent.get(cache, &Map.get(&1, {n, days})) do
      got
    else
      sum = calc_each(7, days - n, cache) + calc_each(9, days - n, cache)
      Agent.update(cache, &Map.put(&1, {n, days}, sum))
      sum
    end
  end
end

{:ok, cache} = Agent.start(fn -> %{} end)
P2.calc(data, 256, cache)
