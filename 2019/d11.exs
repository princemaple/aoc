defmodule L do
  def parse_program(t) do
    t
    |> String.trim
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.map(fn {v, k} -> {k, v} end)
    |> Enum.into(%{})
  end
end

defmodule M do
  def run(program, pointer \\ 0, input, base \\ 0) do
    # if Process.get(:debug) do
    #   IO.inspect {pointer, {program[pointer+1], program[pointer+2], program[pointer+3]}, parse_ins(program[pointer]), input, base}
    # end
    exec(parse_ins(program[pointer]), program, pointer, input, base)
  end

  defp exec([99 | _], m, i, _input, base) do
    {m, i, base}
  end

  defp exec([1, mode1, mode2, mode3], m, i, input, base) do
    {a, b, w} = {deref(mode1, m, i+1, base), deref(mode2, m, i+2, base), deref(mode3, m, i+3, base, :pointer)}
    run(Map.put(m, w, a + b), i + 4, input, base)
  end

  defp exec([2, mode1, mode2, mode3], m, i, input, base) do
    {a, b, w} = {deref(mode1, m, i+1, base), deref(mode2, m, i+2, base), deref(mode3, m, i+3, base, :pointer)}
    run(Map.put(m, w, a * b), i + 4, input, base)
  end

  defp exec([3 | _], m, i, nil, base) do
    input = N.next_color(
      Process.get(:state_pid),
      Process.get(:output_pid) |> Agent.get_and_update(&{&1, []}) |> Enum.reverse
    )
    run(m, i, input, base)
  end

  defp exec([3, mode | _], m, i, input, base) do
    w = deref(mode, m, i + 1, base, :pointer)
    run(Map.put(m, w, input), i + 2, nil, base)
  end

  defp exec([4, mode | _], m, i, input, base) do
    output = deref(mode, m, i + 1, base)
    Agent.update(Process.get(:output_pid), &[output | &1])
    run(m, i + 2, input, base)
  end

  defp exec([5, mode1, mode2, _], m, i, input, base) do
    condition = deref(mode1, m, i + 1, base)
    pointer = deref(mode2, m, i + 2, base)

    if condition != 0 do
      run(m, pointer, input, base)
    else
      run(m, i + 3, input, base)
    end
  end

  defp exec([6, mode1, mode2, _], m, i, input, base) do
    condition = deref(mode1, m, i + 1, base)
    pointer = deref(mode2, m, i + 2, base)

    if condition == 0 do
      run(m, pointer, input, base)
    else
      run(m, i + 3, input, base)
    end
  end

  defp exec([7, mode1, mode2, mode3], m, i, input, base) do
    p1 = deref(mode1, m, i + 1, base)
    p2 = deref(mode2, m, i + 2, base)
    w = deref(mode3, m, i + 3, base, :pointer)

    if p1 < p2 do
      run(Map.put(m, w, 1), i + 4, input, base)
    else
      run(Map.put(m, w, 0), i + 4, input, base)
    end
  end

  defp exec([8, mode1, mode2, mode3], m, i, input, base) do
    p1 = deref(mode1, m, i + 1, base)
    p2 = deref(mode2, m, i + 2, base)
    w = deref(mode3, m, i + 3, base, :pointer)

    if p1 == p2 do
      run(Map.put(m, w, 1), i + 4, input, base)
    else
      run(Map.put(m, w, 0), i + 4, input, base)
    end
  end

  defp exec([9, mode | _], m, i, input, base) do
    offset = deref(mode, m, i + 1, base)
    run(m, i + 2, input, base + offset)
  end

  defp deref(mode, m, i, base, type \\ :value) do do_deref(mode, m, i, base, type) || 0 end

  defp do_deref(0, m, i, _base, :value) do m[m[i]] end
  defp do_deref(1, m, i, _base, _) do m[i] end
  defp do_deref(2, m, i, base, :value) do m[base + m[i]] end
  defp do_deref(0, m, i, _base, :pointer) do m[i] end
  defp do_deref(2, m, i, base, :pointer) do base + m[i] end

  defp parse_ins(ins) do
    {ins, op} = {div(ins, 100), Integer.mod(ins, 100)}
    {ins, c} = {div(ins, 10), Integer.mod(ins, 10)}
    {ins, b} = {div(ins, 10), Integer.mod(ins, 10)}
    a = Integer.mod(ins, 10)
    [op, c, b, a]
  end
end

defmodule N do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def next_color(pid, [color, turn]) do
    GenServer.call(pid, {:next_color, {color, turn}})
  end

  def size(pid) do
    GenServer.call(pid, :size)
  end

  def colors(pid) do
    GenServer.call(pid, :colors)
  end

  def init(_) do
    {:ok, {:up, {0, 0}, %{}}}
  end

  def handle_call({:next_color, {color, turn}}, _from, {dir, coords, colors}) do
    colors = Map.put(colors, coords, color)
    {dir, coords} = calc_next(dir, coords, turn)
    color = colors[coords] || 0
    {:reply, color, {dir, coords, colors}}
  end

  def handle_call(:size, _from, {_dir, _coords, colors} = state) do
    {:reply, map_size(colors), state}
  end

  def handle_call(:colors, _from, {_dir, _coords, colors} = state) do
    {:reply, colors, state}
  end

  defp calc_next(dir, {x, y}, turn) do
    case {dir, turn} do
      {:up, 0} -> {:left, {x - 1, y}}
      {:down, 0} -> {:right, {x + 1, y}}
      {:left, 0} -> {:down, {x, y - 1}}
      {:right, 0} -> {:up, {x, y + 1}}
      {:up, 1} -> {:right, {x + 1, y}}
      {:down, 1} -> {:left, {x - 1, y}}
      {:left, 1} -> {:up, {x, y + 1}}
      {:right, 1} -> {:down, {x, y - 1}}
    end
  end
end

# Process.put(:debug, true)
t = """
3,8,1005,8,290,1106,0,11,0,0,0,104,1,104,0,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,1,8,10,4,10,1002,8,1,28,1006,0,59,3,8,1002,8,-1,10,101,1,10,10,4,10,108,0,8,10,4,10,101,0,8,53,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,0,10,4,10,101,0,8,76,1006,0,81,1,1005,2,10,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,1,10,4,10,1002,8,1,105,3,8,102,-1,8,10,1001,10,1,10,4,10,108,1,8,10,4,10,1001,8,0,126,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,1,8,10,4,10,1002,8,1,148,3,8,102,-1,8,10,101,1,10,10,4,10,1008,8,1,10,4,10,1001,8,0,171,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,0,10,4,10,101,0,8,193,1,1008,8,10,1,106,3,10,1006,0,18,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,225,1,1009,9,10,1006,0,92,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,1001,8,0,254,2,1001,8,10,1,106,11,10,2,102,13,10,1006,0,78,101,1,9,9,1007,9,987,10,1005,10,15,99,109,612,104,0,104,1,21102,1,825594852136,1,21101,0,307,0,1106,0,411,21101,0,825326580628,1,21101,0,318,0,1105,1,411,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21102,179557207043,1,1,21101,0,365,0,1106,0,411,21101,0,46213012483,1,21102,376,1,0,1106,0,411,3,10,104,0,104,0,3,10,104,0,104,0,21101,988648727316,0,1,21102,399,1,0,1105,1,411,21102,988224959252,1,1,21101,0,410,0,1106,0,411,99,109,2,21201,-1,0,1,21101,0,40,2,21102,1,442,3,21101,432,0,0,1105,1,475,109,-2,2105,1,0,0,1,0,0,1,109,2,3,10,204,-1,1001,437,438,453,4,0,1001,437,1,437,108,4,437,10,1006,10,469,1102,0,1,437,109,-2,2105,1,0,0,109,4,2102,1,-1,474,1207,-3,0,10,1006,10,492,21101,0,0,-3,21202,-3,1,1,22102,1,-2,2,21101,0,1,3,21102,511,1,0,1105,1,516,109,-4,2105,1,0,109,5,1207,-3,1,10,1006,10,539,2207,-4,-2,10,1006,10,539,21201,-4,0,-4,1106,0,607,21202,-4,1,1,21201,-3,-1,2,21202,-2,2,3,21101,558,0,0,1106,0,516,22101,0,1,-4,21101,1,0,-1,2207,-4,-2,10,1006,10,577,21102,1,0,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,599,21201,-1,0,1,21101,0,599,0,105,1,474,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2106,0,0
"""

{:ok, output_pid} = Agent.start_link(fn -> [] end)
{:ok, state_pid} = N.start_link

Process.put(:output_pid, output_pid)
Process.put(:state_pid, state_pid)

t |> L.parse_program |> M.run(0)
IO.inspect(N.size(state_pid), label: "part1")

{:ok, output_pid} = Agent.start_link(fn -> [] end)
{:ok, state_pid} = N.start_link

Process.put(:output_pid, output_pid)
Process.put(:state_pid, state_pid)

t |> L.parse_program |> M.run(1)
colors = N.colors(state_pid)
keys = Map.keys(colors)
{min_x, max_x} = keys |> Enum.map(fn {x, _} -> x end) |> Enum.min_max
{min_y, max_y} = keys |> Enum.map(fn {_, y} -> y end) |> Enum.min_max

IO.puts "part2:"

for y <- max_y..min_y do
  for x <- min_x..max_x do
    colors[{x, y}] || 0
  end
  |> Enum.map(fn
    1 -> "#"
    0 -> "_"
  end)
  |> Enum.join("")
  |> IO.puts
end

IO.puts "done"
