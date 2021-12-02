# Title: Day2

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.split(["\r\n", "\n"], trim: true)
  |> Enum.map(&String.split/1)
  |> Enum.map(fn [m, u] -> {m, String.to_integer(u)} end)
  |> tap(&IO.puts(length(&1)))

defmodule P1 do
  def move(data) do
    data
    |> Enum.reduce({0, 0}, fn
      {"forward", unit}, {depth, position} -> {depth, position + unit}
      {"down", unit}, {depth, position} -> {depth + unit, position}
      {"up", unit}, {depth, position} -> {depth - unit, position}
    end)
  end
end

{depth, position} = P1.move(data)

depth * position

defmodule P2 do
  def move(data) do
    data
    |> Enum.reduce({0, 0, 0}, fn
      {"forward", unit}, {depth, aim, position} -> {depth + aim * unit, aim, position + unit}
      {"down", unit}, {depth, aim, position} -> {depth, aim + unit, position}
      {"up", unit}, {depth, aim, position} -> {depth, aim - unit, position}
    end)
  end
end

{depth, _aim, position} = P2.move(data)

depth * position
