# Title: Day13

# ── Untitled ──

[dots, folds] =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n\n", "\r\n\r\n"], trim: true)

dots =
  dots
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(fn line ->
    line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end)
  |> IO.inspect()

folds =
  folds
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&(&1 |> String.split(" ") |> List.last() |> String.split("=")))
  |> Enum.map(fn [axis, n] -> {axis, String.to_integer(n)} end)

defmodule P1 do
  def calc(dots, {"y", n}) do
    dots
    |> Enum.split_with(fn {_x, y} -> y < n end)
    |> then(fn {unchanged, folded} ->
      folded
      |> Enum.map(fn {x, y} ->
        {x, n - (y - n)}
      end)
      |> Kernel.++(unchanged)
      |> Enum.uniq()
    end)
  end

  def calc(dots, {"x", n}) do
    dots
    |> Enum.split_with(fn {x, _y} -> x < n end)
    |> then(fn {unchanged, folded} ->
      folded
      |> Enum.map(fn {x, y} ->
        {n - (x - n), y}
      end)
      |> Kernel.++(unchanged)
      |> Enum.uniq()
    end)
  end
end

P1.calc(dots, hd(folds)) |> length

defmodule P2 do
  def calc(dots, folds) do
    dots =
      folds
      |> Enum.reduce(dots, fn fold, dots ->
        P1.calc(dots, fold)
      end)
      |> MapSet.new()

    {min_x, max_x} = dots |> Enum.map(fn {x, _} -> x end) |> Enum.min_max()
    {min_y, max_y} = dots |> Enum.map(fn {_, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        ({x, y} in dots && "#") || "."
      end
    end
  end
end

P2.calc(dots, folds) |> Enum.each(&IO.puts/1)
