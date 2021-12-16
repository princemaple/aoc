# Title: Day15

# ── Untitled ──

Mix.install([:priority_queue])

grid =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(fn line ->
    line |> String.split("", trim: true) |> Enum.map(&String.to_integer/1)
  end)

grid =
  for {line, row} <- Enum.with_index(grid), {cell, col} <- Enum.with_index(line), into: %{} do
    {{row, col}, cell}
  end

defmodule D15 do
  @offsets [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def walk({row, col}, r, q, grid) do
    {q, grid} =
      @offsets
      |> Enum.map(fn {dr, dc} -> {row + dr, col + dc} end)
      |> Enum.map(&{&1, grid[&1]})
      |> Enum.reject(&is_nil(elem(&1, 1)))
      |> Enum.reduce({q, grid}, fn {pos, risk}, {q, grid} ->
        {PriorityQueue.put(q, risk + r, pos), Map.delete(grid, pos)}
      end)

    {{risk, next}, q} = PriorityQueue.pop(q)
    {next, risk, q, grid}
  end

  def solve1(grid) do
    max = grid |> Map.keys() |> Enum.max()

    Stream.iterate(
      {{0, 0}, 0, PriorityQueue.new(), Map.delete(grid, {0, 0})},
      fn {next, risk, q, grid} ->
        D15.walk(next, risk, q, grid)
      end
    )
    |> Stream.drop_while(fn
      {^max, _, _, _} -> false
      _ -> true
    end)
    |> Enum.at(0)
    |> elem(1)
    |> IO.inspect()
  end

  def solve2(grid) do
    offset = grid |> Enum.filter(&match?({{0, _}, _}, &1)) |> length

    grid
    |> Enum.map(fn {{row, col}, v} ->
      0..4
      |> Enum.map(
        &{{row + offset * &1, col},
         if (v = v + &1) > 9 do
           v - 9
         else
           v
         end}
      )
    end)
    |> List.flatten()
    |> Enum.map(fn {{row, col}, v} ->
      0..4
      |> Enum.map(
        &{{row, col + offset * &1},
         if (v = v + &1) > 9 do
           v - 9
         else
           v
         end}
      )
    end)
    |> List.flatten()
    |> Map.new()
    |> solve1()
  end
end

# ── P1 ── (⎇ from Untitled)

# D15.solve1(grid)

# ── P2 ── (⎇ from Untitled)

# D15.solve2(grid)
