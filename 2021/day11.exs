# Title: Day11

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&(&1 |> String.split("", trim: true) |> Enum.map(fn n -> String.to_integer(n) end)))

data =
  for {line, row} <- Enum.with_index(data), {point, col} <- Enum.with_index(line), into: %{} do
    {{row, col}, point}
  end

defmodule P1 do
  @offsets (for x <- -1..1, y <- -1..1, {x, y} != {0, 0} do
              {x, y}
            end)

  def calc(data, steps) do
    data = Map.new(data, fn {coords, v} -> {coords, {v, false}} end)

    Enum.reduce(1..steps, {0, data}, fn _, {sum, data} ->
      {count, data} = step(data)
      {sum + count, data}
    end)
    |> elem(0)
  end

  def step(data) do
    Stream.iterate(
      {0, Map.new(data, fn {coords, {v, f}} -> {coords, {v + 1, f}} end)},
      fn {_, data} ->
        data
        |> then(fn data ->
          flashing =
            Enum.filter(data, fn
              {_, {power, false}} when power > 9 -> true
              _ -> false
            end)

          {length(flashing),
           flashing
           |> Enum.reduce(data, fn {{x, y}, _}, data ->
             @offsets
             |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
             |> Enum.filter(fn coords -> Map.has_key?(data, coords) end)
             |> Enum.reduce(data, fn coords, data ->
               Map.update!(data, coords, fn {v, f} -> {v + 1, f} end)
             end)
             |> Map.update!({x, y}, fn {v, _} -> {v, true} end)
           end)}
        end)
      end
    )
    |> Stream.drop(1)
    |> Enum.reduce_while(0, fn
      {0, data}, sum ->
        {:halt,
         {sum,
          Map.new(data, fn
            {k, {power, _}} when power > 9 -> {k, {0, false}}
            {k, v} -> {k, v}
          end)}}

      {count, _}, sum ->
        {:cont, count + sum}
    end)
  end
end

P1.calc(data, 100)

defmodule P2 do
  def calc(data) do
    data = Map.new(data, fn {coords, v} -> {coords, {v, false}} end)

    Stream.iterate({0, data}, fn {_, data} ->
      P1.step(data)
    end)
    |> Enum.find_index(fn
      {100, _} -> true
      _ -> false
    end)
  end
end

P2.calc(data)
