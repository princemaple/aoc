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

defmodule D19 do
  def prepare(data) do
    data
    |> Enum.map(fn {scanner, beacons} -> {scanner, {length(beacons), quadrants(beacons)}} end)
    |> Map.new()
  end

  @rs [
    &D19.not_rotate/1,
    &D19.rotate_x_cw/1,
    &D19.rotate_y_cw/1,
    &D19.rotate_z_cw/1,
    &D19.rotate_x_ac/1,
    &D19.rotate_y_ac/1,
    &D19.rotate_z_ac/1
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
  def rotate_x_cw([x, y, z]), do: [x, z, -y]
  def rotate_y_cw([x, y, z]), do: [-z, y, x]
  def rotate_z_cw([x, y, z]), do: [y, -x, z]
  def rotate_x_ac([x, y, z]), do: [x, -z, y]
  def rotate_y_ac([x, y, z]), do: [z, y, -x]
  def rotate_z_ac([x, y, z]), do: [-y, x, z]

  def detect_connection(q1, qs2) do
    Enum.find_value(Enum.with_index(qs2), fn {q2, i2} ->
      for [x1, y1, z1] <- q1, [x2, y2, z2] <- q2 do
        {x1 - x2, y1 - y2, z1 - z2}
      end
      |> Enum.frequencies()
      |> Enum.find(&(elem(&1, 1) >= 12))
      |> then(fn
        nil -> nil
        {diff, count} -> {i2, diff, count}
      end)
    end)
  end

  def total({s1, s2, {_, _, count}}, {sum, seen}, data) do
    {sum + if(s1 in seen, do: 0, else: elem(data[s1], 0)) +
       if(s2 in seen, do: 0, else: elem(data[s2], 0)) - count,
     seen
     |> MapSet.put(s1)
     |> MapSet.put(s2)}
  end

  def solve1(data) do
    data = prepare(data)

    for {s1, {_, qs1}} <- data, {s2, {_, qs2}} <- data, s1 < s2 do
      {s1, s2, detect_connection(hd(qs1), qs2)}
    end
    |> Enum.reject(&is_nil(elem(&1, 2)))
    |> Enum.reduce({0, MapSet.new()}, &total(&1, &2, data))
  end

  def connect([{s1, {_, qs1}} | rest], qi) do
    Enum.reduce(rest, qi, fn {s2, {_, qs2}} = item, qi ->
      with {{i1, [x1, y1, z1]}, nil} <- {qi[s1], qi[s2]},
           {i2, {x2, y2, z2}, _count} <- detect_connection(Enum.at(qs1, i1), qs2) do
        connect(
          [item | rest -- [item]],
          Map.put(qi, s2, {i2, [x1 + x2, y1 + y2, z1 + z2]})
        )
      else
        _ ->
          qi
      end
    end)
  end

  def solve2(data) do
    data = prepare(data)

    coords =
      data
      |> Enum.to_list()
      |> connect(%{0 => {0, [0, 0, 0]}})

    for {s1, {_, [x1, y1, z1]}} <- coords, {s2, {_, [x2, y2, z2]}} <- coords, s1 < s2 do
      abs(x2 - x1) + abs(y2 - y1) + abs(z2 - z1)
    end
    |> Enum.max()
  end
end

# ── P1 ──

D19.solve1(data)

# ── P2 ──

D19.solve2(data)
