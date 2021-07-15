defmodule M do
  def x(t) do
    [l1, l2] = t |> String.split |> Enum.map(&(&1 |> String.split(",")))
    # intersections = MapSet.intersection(ps(l1), ps(l2))
    p1s = ps(l1)
    p2s = ps(l2)

    (p1s -- (p1s -- p2s))
    |> Enum.map(fn loc -> Enum.find_index(p1s, & &1 == loc) + Enum.find_index(p2s, & &1 == loc) + 2 end)
    |> Enum.min
  end

  @dir %{
    "U" => :up,
    "D" => :down,
    "L" => :left,
    "R" => :right
  }

  # defp ps(ins, loc \\ {0, 0}, ds \\ MapSet.new)
  defp ps(ins, loc \\ {0, 0}, ds \\ [])

  defp ps([], _loc, ds) do
    Enum.reverse(ds)
  end

  defp ps([<< <<d::utf8>> <> b >> | rest], {x, y}, ds) when d in 'UDLR' do
    {{x, y}, ds} = pps(String.to_integer(b), @dir[<<d>>], x, y, ds)
    ps(rest, {x, y}, ds)
  end

  defp pps(0, _, x, y, ds) do
    {{x, y}, ds}
  end

  defp pps(n, :up, x, y, ds) do
    # pps(n - 1, :up, x, y + 1, MapSet.put(ds, {x, y + 1}))
    pps(n - 1, :up, x, y + 1, [{x, y + 1} | ds])
  end

  defp pps(n, :down, x, y, ds) do
    # pps(n - 1, :down, x, y - 1, MapSet.put(ds, {x, y - 1}))
    pps(n - 1, :down, x, y - 1, [{x, y - 1} | ds])
  end

  defp pps(n, :left, x, y, ds) do
    # pps(n - 1, :left, x - 1, y, MapSet.put(ds, {x - 1, y}))
    pps(n - 1, :left, x - 1, y, [{x - 1, y} | ds])
  end

  defp pps(n, :right, x, y, ds) do
    # pps(n - 1, :right, x + 1, y, MapSet.put(ds, {x + 1, y}))
    pps(n - 1, :right, x + 1, y, [{x + 1, y} | ds])
  end
en
