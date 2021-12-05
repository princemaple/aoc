# Title: Day5

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split(" -> ")
    |> Enum.map(&(&1 |> String.split(",") |> Enum.map(fn n -> String.to_integer(n) end)))
  end)

defmodule P1 do
  def calc(data) do
    data
    |> Enum.filter(fn [[x1, y1], [x2, y2]] -> x1 == x2 or y1 == y2 end)
    |> Enum.map(fn [[x1, y1], [x2, y2]] ->
      if x1 == x2 do
        for y <- y1..y2, do: {x1, y}
      else
        for x <- x1..x2, do: {x, y1}
      end
    end)
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_k, v} -> v >= 2 end)
    |> length
  end
end

P1.calc(data)

defmodule P2 do
  def calc(data) do
    data
    |> Enum.map(fn [[x1, y1], [x2, y2]] ->
      cond do
        x1 == x2 ->
          for y <- y1..y2, do: {x1, y}

        y1 == y2 ->
          for x <- x1..x2, do: {x, y1}

        true ->
          Enum.zip(x1..x2, y1..y2)
      end
    end)
    |> List.flatten()
    |> Enum.frequencies()
    |> Enum.filter(fn {_k, v} -> v >= 2 end)
    |> length
  end
end

P2.calc(data)
