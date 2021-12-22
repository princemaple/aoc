# Title: Day22

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\r\n", "\n"], trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split()
    |> then(fn [on_off, coords] ->
      coords
      |> String.replace(~r/x=|y=|z=/, "")
      |> String.split(",")
      |> Enum.map(&Code.eval_string/1)
      |> Enum.map(&elem(&1, 0))
      |> then(&{on_off == "on", &1})
    end)
  end)

defmodule D22 do
  def remove(
        [x1min..x1max, y1min..y1max, z1min..z1max] = c1,
        [x2min..x2max, y2min..y2max, z2min..z2max] = c2
      ) do
    if [c1, c2]
       |> Enum.zip()
       |> Enum.any?(fn {left, right} -> Range.disjoint?(left, right) end) do
      [c1]
    else
      [
        [x1min..x1max//1, y1min..y1max//1, z1min..(z2min - 1)//1],
        [x1min..x1max//1, y1min..y1max//1, (z2max + 1)..z1max//1],
        [x1min..(x2min - 1)//1, y1min..y1max//1, max(z1min, z2min)..min(z1max, z2max)//1],
        [(x2max + 1)..x1max//1, y1min..y1max//1, max(z1min, z2min)..min(z1max, z2max)//1],
        [
          max(x1min, x2min)..min(x1max, x2max)//1,
          y1min..(y2min - 1)//1,
          max(z1min, z2min)..min(z1max, z2max)//1
        ],
        [
          max(x1min, x2min)..min(x1max, x2max)//1,
          (y2max + 1)..y1max//1,
          max(z1min, z2min)..min(z1max, z2max)//1
        ]
      ]
      |> Enum.reject(fn c -> Enum.any?(c, &(Range.size(&1) == 0)) end)
    end
  end

  def limit(a..b) do
    if Range.disjoint?(a..b, -50..50) do
      1..0//1
    else
      max(-50, a)..min(b, 50)
    end
  end

  def solve(on, [], _) do
    on
    |> Enum.map(fn c ->
      c
      |> Enum.map(&Range.size/1)
      |> Enum.product()
    end)
    |> Enum.sum()
  end

  def solve(on, [{add?, c2} | instructions], limit) do
    c2 = Enum.map(c2, limit)

    Enum.flat_map(on, fn c1 ->
      remove(c1, c2)
    end)
    |> then(fn on ->
      if add? do
        [c2 | on]
      else
        on
      end
    end)
    |> solve(instructions, limit)
  end
end

# ── P1 ──

D22.solve([], data, &D22.limit/1)

# ── P2 ──

D22.solve([], data, & &1)
