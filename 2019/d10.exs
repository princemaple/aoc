defmodule M do
  def x(m) do
    m
    |> Enum.map(fn {coords, m} -> {coords, map_size(m)} end)
    |> Enum.max_by(&elem(&1, 1))
  end

  def y(m, {{r, c}, _}) do
    dirs = Enum.into(m, %{})[{r, c}]

    key =
      dirs
      |> Map.keys
      |> Enum.sort_by(fn
        :up -> {0, nil}
        {tan, false, true} -> {1, tan}
        {tan, true, true} -> {2, tan}
        :down -> {3, nil}
        {tan, true, false} -> {4, tan}
        {tan, false, false} -> {5, tan}
      end)
      |> Enum.drop(199)
      |> List.first

    dirs[key]
  end

  def analyse(m) do
    for {{r, c}, true} <- m do
      {{r, c},
      for {{rr, cc}, true} <- m, not(rr == r and cc == c) do
        case cc - c do
          0 -> if rr < r do
            {:up, {rr, cc}}
          else
            {:down, {rr, cc}}
          end
          _ -> {{(rr - r) / (cc - c), rr > r, cc > c}, {rr, cc}}
        end
      end
      |> Enum.group_by(&elem(&1, 0))
      |> Enum.map(fn {k, v} -> {k, Enum.map(v, fn {_, coords} -> coords end)} end)
      |> Enum.into(%{})}
    end
  end

  def clean(t) do
    t
    |> String.trim
    |> String.split
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      line
      |> Enum.with_index
      |> Enum.map(fn {char, col} ->
        {{row, col}, char == "#"}
      end)
    end)
    |> Enum.into(%{})
  end
end

test = """
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
"""

mt = test |> M.clean |> M.analyse
t1 = M.x(mt)
IO.inspect t1
IO.inspect M.y(mt, t1)

t = """
.#..#..##.#...###.#............#.
.....#..........##..#..#####.#..#
#....#...#..#.......#...........#
.#....#....#....#.#...#.#.#.#....
..#..#.....#.......###.#.#.##....
...#.##.###..#....#........#..#.#
..#.##..#.#.#...##..........#...#
..#..#.......................#..#
...#..#.#...##.#...#.#..#.#......
......#......#.....#.............
.###..#.#..#...#..#.#.......##..#
.#...#.................###......#
#.#.......#..####.#..##.###.....#
.#.#..#.#...##.#.#..#..##.#.#.#..
##...#....#...#....##....#.#....#
......#..#......#.#.....##..#.#..
##.###.....#.#.###.#..#..#..###..
#...........#.#..#..#..#....#....
..........#.#.#..#.###...#.....#.
...#.###........##..#..##........
.###.....#.#.###...##.........#..
#.#...##.....#.#.........#..#.###
..##..##........#........#......#
..####......#...#..........#.#...
......##...##.#........#...##.##.
.#..###...#.......#........#....#
...##...#..#...#..#..#.#.#...#...
....#......#.#............##.....
#......####...#.....#...#......#.
...#............#...#..#.#.#..#.#
.#...#....###.####....#.#........
#.#...##...#.##...#....#.#..##.#.
.#....#.###..#..##.#.##...#.#..##
"""
m = t |> M.clean |> M.analyse
p1 = M.x(m)
IO.inspect p1

IO.inspect M.y(m, p1)
