# Title: Day9

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
  @offsets [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]

  def calc(data) do
    data
    |> Enum.filter(fn {{row, col}, point} ->
      @offsets
      |> Enum.all?(fn {dr, dc} ->
        (data[{row + dr, col + dc}] || 10) > point
      end)
    end)
    |> Enum.map(&(elem(&1, 1) + 1))
    |> Enum.sum()
  end
end

P1.calc(data)

defmodule P2 do
  @offsets [{-1, 0}, {1, 0}, {0, 0}, {0, -1}, {0, 1}]

  def calc(data) do
    data
    |> Enum.reject(fn {_, v} -> v == 9 end)
    |> Enum.reduce(%{}, fn item, path ->
      {_, path} = mark_low(item, path, data)
      path
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.frequencies()
    |> Map.values()
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.product()
  end

  defp mark_low({{row, col} = coords, _point} = current, path, data) do
    if dest = path[coords] do
      {dest, path}
    else
      low =
        @offsets
        |> Enum.map(fn {dr, dc} ->
          point = {row + dr, col + dc}
          {point, data[point] || 10}
        end)
        |> Enum.min_by(&elem(&1, 1))

      if low == current do
        {elem(low, 0), Map.put(path, coords, elem(low, 0))}
      else
        {dest, path} = mark_low(low, path, data)
        {dest, Map.put(path, coords, dest)}
      end
    end
  end
end

P2.calc(data)
