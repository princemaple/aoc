# Title: Day14

# ── Untitled ──

[data, map] =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n\n", "\r\n\r\n"], trim: true)

data = String.split(data, "", trim: true)

map =
  map
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&String.split(&1, " -> "))
  |> Enum.map(fn [template, insert] -> {template, insert} end)
  |> Map.new()

defmodule P1 do
  def step([char1, char2 | rest], map) do
    [char1, map[char1 <> char2] | step([char2 | rest], map)]
  end

  def step([char], _map), do: [char]
end

1..10
|> Enum.reduce(data, fn _, data -> P1.step(data, map) end)
|> Enum.frequencies()
|> Map.values()
|> Enum.min_max()
|> then(fn {min, max} -> max - min end)

defmodule P2 do
  def step(data, map) do
    data
    |> Enum.flat_map(fn {<<c1, c2>> = k, v} ->
      [{<<c1>> <> map[k], v}, {map[k] <> <<c2>>, v}]
    end)
    |> Enum.group_by(&elem(&1, 0))
    |> Map.new(fn {k, v} -> {k, v |> Enum.map(&elem(&1, 1)) |> Enum.sum()} end)
  end
end

1..40
|> Enum.reduce(
  data
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(fn [c1, c2] -> c1 <> c2 end)
  |> Enum.frequencies(),
  fn _, data -> P2.step(data, map) end
)
|> then(fn map ->
  [{<<c, _>>, n} | rest] = Enum.to_list(map)

  Enum.reduce(rest, %{<<c>> => n}, fn {<<_, c>>, n}, acc ->
    Map.update(acc, <<c>>, n, &(&1 + n))
  end)
end)
|> Map.values()
|> Enum.min_max()
|> then(fn {min, max} -> max - min end)
