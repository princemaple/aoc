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

  def walk({row, col}, r, q, seen, grid) do
    {q, seen} =
      @offsets
      |> Enum.map(fn {dr, dc} -> {row + dr, col + dc} end)
      |> Enum.map(&{&1, grid[&1]})
      |> Enum.reject(&Map.has_key?(seen, elem(&1, 0)))
      |> Enum.reject(&is_nil(elem(&1, 1)))
      |> Enum.reduce({q, seen}, fn {pos, risk}, {q, seen} ->
        {PriorityQueue.put(q, risk + r, pos), Map.put(seen, pos, risk + r)}
      end)

    {{risk, next}, q} = PriorityQueue.pop(q)
    {next, risk, q, seen}
  end

  def solve1(grid) do
    max = grid |> Map.keys() |> Enum.max()

    Stream.iterate(
      {
        {{0, 0}, 0, PriorityQueue.new(), %{{0, 0} => 0}},
        {max, grid[max], PriorityQueue.new(), %{max => grid[max]}}
      },
      fn {{p1, r1, q1, s1} = t1, {p2, r2, q2, s2} = t2} ->
        if r1 <= r2 do
          {D15.walk(p1, r1, q1, s1, grid), t2}
        else
          {t1, D15.walk(p2, r2, q2, s2, grid)}
        end
      end
    )
    |> Stream.drop_while(fn
      {{p1, _, _, seen1}, {p2, _, _, seen2}} ->
        not (is_map_key(seen2, p1) or is_map_key(seen1, p2))
    end)
    |> Enum.take(1)
    |> List.first()
    |> then(fn
      {{p1, risk1, _, seen1}, {p2, risk2, _, seen2}} ->
        if is_map_key(seen1, p2) do
          seen1[p2] + risk2 - grid[p2]
        else
          seen2[p1] + risk1 - grid[p1]
        end
    end)
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
