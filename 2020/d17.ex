t = """
..#....#
##.#..##
.###....
#....#.#
#.######
##.#....
#.......
.#......
"""

defmodule Util do
  def permutations(_, 0), do: [[]]

  def permutations(list, n),
    do: for(elem <- list, rest <- permutations(list -- [elem], n - 1), do: [elem | rest])
end

defmodule D17 do
  def parse(text, dimension) do
    rows =
      text
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ""))

    for {row, y} <- Enum.with_index(rows) do
      for {cube, x} <- Enum.with_index(row) do
        cube = if cube == "#", do: true, else: false

        {case dimension do
           3 -> {x, y, 0}
           4 -> {x, y, 0, 0}
         end, cube}
      end
    end
    |> List.flatten()
    |> Enum.into(%{})
  end

  def solve(data, 0, _) do
    Enum.count(data, fn {_, is_active} -> is_active end)
  end

  def solve(data, iteration, dimension) do
    data
    |> Enum.filter(fn {_, is_active} -> is_active end)
    |> Enum.reduce(%{}, fn {cube, is_active}, dim ->
      Enum.reduce(neighbours(cube, dimension), dim, fn neighbour, dim ->
        {init, inc} =
          if is_active do
            {1, &Kernel.+(&1, 1)}
          else
            {0, & &1}
          end

        Map.update(dim, neighbour, init, inc)
      end)
    end)
    |> Enum.map(fn {cube, count} ->
      if data[cube] do
        if count in [2, 3] do
          {cube, true}
        else
          {cube, false}
        end
      else
        if count == 3 do
          {cube, true}
        else
          {cube, false}
        end
      end
    end)
    |> Enum.into(%{})
    |> solve(iteration - 1, dimension)
  end

  @offsets1 Util.permutations(
              [0, 0, 0, 1, 1, 1, -1, -1, -1],
              3
            )
            |> Enum.uniq()
            |> Kernel.--([[0, 0, 0]])
            |> Enum.map(&List.to_tuple/1)

  @offsets2 Util.permutations(
              [0, 0, 0, 0, 1, 1, 1, 1, -1, -1, -1, -1],
              4
            )
            |> Enum.uniq()
            |> Kernel.--([[0, 0, 0, 0]])
            |> Enum.map(&List.to_tuple/1)

  def neighbours({x, y, z}, 3) do
    for {dx, dy, dz} <- @offsets1 do
      {x + dx, y + dy, z + dz}
    end
  end

  def neighbours({x, y, z, w}, 4) do
    for {dx, dy, dz, dw} <- @offsets2 do
      {x + dx, y + dy, z + dz, w + dw}
    end
  end
end

t |> D17.parse(3) |> D17.solve(6, 3) |> IO.inspect()
t |> D17.parse(4) |> D17.solve(6, 4) |> IO.inspect()
