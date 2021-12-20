# Title: Day20

# ── Untitled ──

{alg, pic} =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\r\n\r\n", "\n\n"], trim: true)
  |> then(fn [alg, pic] ->
    {String.replace(alg, ["\n", "\r\n"], ""),
     pic |> String.split() |> Enum.map(&String.split(&1, "", trim: true))}
  end)

alg =
  alg
  |> String.split("", trim: true)
  |> Enum.with_index()
  |> Enum.map(fn {k, v} -> {v, (k == "#" && 1) || 0} end)
  |> Map.new()

pic =
  for {line, row} <- Enum.with_index(pic), {cell, col} <- Enum.with_index(line), into: %{} do
    {{row, col}, (cell == "#" && 1) || 0}
  end

defmodule D20 do
  import Bitwise

  def enhance(pic, alg, count, new_pic) do
    field = count - 1 &&& alg[0]
    {{min_row, min_col}, {max_row, max_col}} = pic |> Map.keys() |> Enum.min_max()

    for row <- (min_row - 2)..(max_row + 2), col <- (min_col - 2)..(max_col + 2), into: new_pic do
      {row, col}
      |> neighbours
      |> Enum.map(&Map.get(pic, &1, field))
      |> Integer.undigits(2)
      |> then(fn i -> {{row, col}, alg[i]} end)
    end
  end

  def neighbours({row, col}) do
    for row_offset <- -1..1, col_offset <- -1..1 do
      {row + row_offset, col + col_offset}
    end
  end

  def solve(pic, alg, times) do
    new_pic =
      Enum.reduce(1..times, pic, fn count, pic ->
        D20.enhance(pic, alg, count, %{})
      end)

    {{min_row, min_col}, {max_row, max_col}} = new_pic |> Map.keys() |> Enum.min_max()

    for row <- min_row..max_row do
      for col <- min_col..max_col do
        (new_pic[{row, col}] == 1 && "#") || "."
      end
      |> IO.puts()
    end

    for row <- min_row..max_row, col <- min_col..max_col do
      new_pic[{row, col}] == 1
    end
    |> Enum.reject(&(!&1))
    |> Enum.count()
  end
end

# ── P1 ──

D20.solve(pic, alg, 2)

# ── P2 ──

D20.solve(pic, alg, 50)
