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
  def run(program, pointer, input, base) do
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
    {m, i, base}
  end

  defp exec([3, mode | _], m, i, input, base) do
    w = deref(mode, m, i + 1, base, :pointer)
    run(Map.put(m, w, input), i + 2, nil, base)
  end

  defp exec([4, mode | _], m, i, input, base) do
    output = deref(mode, m, i + 1, base)
    Agent.update(Process.get(:pid), &[output | &1])
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

{:ok, a1} = Agent.start_link(fn -> [] end)
Process.put(:pid, a1)
t1 = """
109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
"""
t1 |> L.parse_program |> M.run(0, 1, 0)
[109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] = (a1 |> Agent.get(& &1) |> Enum.reverse)


{:ok, a2} = Agent.start_link(fn -> [] end)
Process.put(:pid, a2)
t2 = """
1102,34915192,34915192,7,4,7,99,0
"""
t2 |> L.parse_program |> M.run(0, 1, 0)
[1219070632396864] = (a2 |> Agent.get(& &1) |> Enum.reverse)

{:ok, a3} = Agent.start_link(fn -> [] end)
Process.put(:pid, a3)
t3 = """
104,1125899906842624,99
"""
t3 |> L.parse_program |> M.run(0, 1, 0)
[1125899906842624] = (a3 |> Agent.get(& &1) |> Enum.reverse)

# Process.put(:debug, true)
t = """
...MY_INPUT...
"""

{:ok, a4} = Agent.start_link(fn -> [] end)
Process.put(:pid, a4)
t |> L.parse_program |> M.run(0, 1, 0)
IO.inspect (a4 |> Agent.get(& &1) |> Enum.reverse)

{:ok, a5} = Agent.start_link(fn -> [] end)
Process.put(:pid, a5)
t |> L.parse_program |> M.run(0, 2, 0)
IO.inspect (a5 |> Agent.get(& &1) |> Enum.reverse)

IO.puts "done"
