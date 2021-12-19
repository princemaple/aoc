# Title: Day19

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(~r/^--- /m, trim: true)
  |> Enum.map(
    &(&1
      |> String.split(" ---", trim: true)
      |> then(fn ["scanner " <> scanner, beacons] ->
        {String.to_integer(scanner),
         beacons
         |> String.split(["\r\n", "\n"], trim: true)
         |> Enum.map(fn beacon ->
           beacon |> String.split(",") |> Enum.map(fn n -> String.to_integer(n) end)
         end)}
      end))
  )
  |> Map.new()

1

defmodule D18 do
  def prepare(data) do
    data
    |> Enum.map(fn {scanner, beacons} -> {scanner, {length(beacons), quadrants(beacons)}} end)
    |> Map.new()
  end

  @rs [
    &D18.not_rotate/1,
    &D18.rotate_x_cw/1,
    &D18.rotate_y_cw/1,
    &D18.rotate_z_cw/1,
    &D18.rotate_x_ac/1,
    &D18.rotate_y_ac/1,
    &D18.rotate_z_ac/1
  ]

  def quadrants(beacons) do
    beacons
    |> Stream.map(fn beacon ->
      for r1 <- @rs, r2 <- @rs, r3 <- @rs do
        beacon |> r1.() |> r2.() |> r3.()
      end
      |> Enum.uniq()
    end)
    |> Stream.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def not_rotate(point), do: point

  def rotate_x_cw([x, y, z]) do
    [x, z, -y]
  end

  def rotate_y_cw([x, y, z]) do
    [-z, y, x]
  end

  def rotate_z_cw([x, y, z]) do
    [y, -x, z]
  end

  def rotate_x_ac([x, y, z]) do
    [x, -z, y]
  end

  def rotate_y_ac([x, y, z]) do
    [z, y, -x]
  end

  def rotate_z_ac([x, y, z]) do
    [-y, x, z]
  end

  def detect_connection([q1 | _qs1], qs2) do
    Enum.find_value(qs2, fn q2 ->
      for [x1, y1, z1] <- q1, [x2, y2, z2] <- q2 do
        {x1 - x2, y1 - y2, z1 - z2}
      end
      |> Enum.frequencies()
      |> Enum.find(&(elem(&1, 1) >= 12))
      |> then(fn
        nil -> nil
        {_, count} -> count
      end)
    end)
  end

  def total({s1, s2, count}, {sum, seen}, data) do
    {sum + if(s1 in seen, do: 0, else: elem(data[s1], 0)) +
       if(s2 in seen, do: 0, else: elem(data[s2], 0)) - count,
     seen
     |> MapSet.put(s1)
     |> MapSet.put(s2)}
  end

  def solve1(data) do
    data = prepare(data)

    for {s1, {_, qs1}} <- data, {s2, {_, qs2}} <- data, s1 < s2 do
      {s1, s2, detect_connection(qs1, qs2)}
    end
    |> Enum.reject(&is_nil(elem(&1, 2)))
    |> Enum.reduce({0, MapSet.new()}, &total(&1, &2, data))
  end

  def detect_connection2(q1, qs2, s2) do
    Enum.find_value(Enum.with_index(qs2), fn {q2, i2} ->
      for [x1, y1, z1] = p1 <- q1, [x2, y2, z2] = p2 <- q2 do
        {{x1 - x2, y1 - y2, z1 - z2}, {p1, p2}}
      end
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.find(&(length(elem(&1, 1)) >= 12))
      |> then(fn
        nil ->
          nil

        {_diff, [point | _points]} ->
          Agent.update(P2, &Map.put(&1, s2, i2))
          point
      end)
    end)
  end

  def locate([{s1, s2, {[x1, y1, z1], [x2, y2, z2]}} = item | rest], map) do
    if !Map.has_key?(map, s1) and Map.has_key?(map, s2) do
      [x, y, z] = map[s2]
      {rest, Map.put(map, s1, [x + x2 - x1, y + y2 - y1, z + z2 - z1])}
    else
      if !Map.has_key?(map, s2) and Map.has_key?(map, s1) do
        [x, y, z] = map[s1]
        {rest, Map.put(map, s2, [x + x1 - x2, y + y1 - y2, z + z1 - z2])}
      else
        {rest ++ [item], map}
      end
    end
  end

  def connect([{s1, {_, qs1}} | rest], acc \\ []) do
    Enum.reduce(rest, acc, fn {s2, {_, qs2}} = item, acc ->
      i1 = Agent.get(P2, &Map.get(&1, s1))
      i2 = Agent.get(P2, &Map.get(&1, s2))

      case {i1, i2} do
        {i1, nil} when not is_nil(i1) ->
          connect(
            [item | rest -- [item]],
            [{s1, s2, detect_connection2(Enum.at(qs1, i1), qs2, s2)} | acc]
          )

        {_i1, _i2} ->
          acc
      end
    end)
  end

  def solve2(data) do
    data = prepare(data)

    Agent.start_link(fn -> %{0 => 0} end, name: P2)

    coords =
      data
      |> Enum.to_list()
      |> connect([])
      |> Enum.reject(&is_nil(elem(&1, 2)))
      |> IO.inspect()
      |> Enum.sort()
      |> then(fn [{s1, s2, {[x1, y1, z1], [x2, y2, z2]}} | rest] ->
        Stream.iterate({rest, %{s1 => [0, 0, 0], s2 => [-x2 + x1, -y2 + y1, -z2 + z1]}}, fn {rest,
                                                                                             map} ->
          locate(rest, map)
        end)
        |> Enum.find_value(fn
          {[], map} -> map
          _ -> false
        end)
      end)
      |> IO.inspect()

    for {s1, [x1, y1, z1]} <- coords, {s2, [x2, y2, z2]} <- coords, s1 < s2 do
      abs(x2 - x1) + abs(y2 - y1) + abs(z2 - z1)
    end
    |> Enum.max()
  end
end

# ── P1 ──

D18.solve1(data)

# ── P2 ──

Agent.stop(P2)

D18.solve2(data)
