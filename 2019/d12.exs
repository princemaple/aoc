defmodule L do
  def parse(t) do
    t
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn s -> s |> String.split() |> Enum.map(&String.to_integer/1) end)
    |> Enum.with_index
    |> Enum.map(fn {[x, y, z], i} -> {i, {x, y, z}, {0, 0, 0}} end)
  end

  def compare(source, target) when source < target, do: 1
  def compare(source, target) when source > target, do: -1
  def compare(source, target) when source == target, do: 0
end

defmodule M do
  import L

  def x(t, step_count) do
    t
    |> parse
    |> step(step_count)
    |> Enum.map(fn {_, coords, velocity} -> energy(coords) * energy(velocity) end)
    |> Enum.sum
  end

  def step(state, 0), do: state

  def step(state, count) do
    for {i, {x, y, z} = coords, velocity} <- state do
      velocity =
        [
          velocity |
          for {j, {xx, yy, zz}, _} <- state, i != j do
            {compare(x, xx), compare(y, yy), compare(z, zz)}
          end
        ] |> Enum.reduce(&add/2)

      coords = add(coords, velocity)

      {i, coords, velocity}
    end
    |> step(count - 1)
  end

  def add({dvx, dvy, dvz}, {vx, vy, vz}) do
    {vx + dvx, vy + dvy, vz + dvz}
  end

  def energy({a, b, c}) do
    abs(a) + abs(b) + abs(c)
  end
end

defmodule N do
  import L

  def y(t) do
    state = parse(t)

    [:x, :y, :z]
    |> Enum.map(&find_repeatition(&1, state))
    |> Enum.map(fn {item, set} -> {item, MapSet.size(set)} end)
  end

  def find_repeatition(which, state) do
    state = Enum.map(state, &extract(which, &1))
    set = MapSet.new([state])
    step_til_repeat(state, set)
  end

  defp extract(:x, {i, {x, _, _}, {vx, _, _}}) do
    {i, x, vx}
  end

  defp extract(:y, {i, {_, y, _}, {_, vy, _}}) do
    {i, y, vy}
  end

  defp extract(:z, {i, {_, _, z}, {_, _, vz}}) do
    {i, z, vz}
  end

  def step_til_repeat(state, set) do
    state =
      for {i, c, v} <- state do
        v =
          [
            v |
            for {j, cc, _} <- state, i != j do
              compare(c, cc)
            end
          ] |> Enum.reduce(&Kernel.+/2)

        c = c + v

        {i, c, v}
      end

    if MapSet.member?(set, state) do
      {state, set}
    else
      step_til_repeat(state, MapSet.put(set, state))
    end
  end
end

t = """
14 4 5
12 10 8
1 7 -10
16 -5 3
"""

IO.inspect(M.x(t, 1000))
IO.inspect(N.y(t))
