defmodule P do
  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
end

defmodule L do
  def x(program, configs) do
    [a, b, c, d, e] =
      Enum.map(configs, fn config ->
        {:ok, pid} = M.start(config, program)
        Process.monitor(pid)
        pid
      end)

    send(a, {:input, 0})

    listen({a,b,c,d,e}, nil)
  end

  defp listen({a,b,c,d,e}, e_value) do
    receive do
      {:output, ^a, o} ->
        send(b, {:input, o})
        listen({a,b,c,d,e}, e_value)
      {:output, ^b, o} ->
        send(c, {:input, o})
        listen({a,b,c,d,e}, e_value)
      {:output, ^c, o} ->
        send(d, {:input, o})
        listen({a,b,c,d,e}, e_value)
      {:output, ^d, o} ->
        send(e, {:input, o})
        listen({a,b,c,d,e}, e_value)
      {:output, ^e, o} ->
        send(a, {:input, o})
        listen({a,b,c,d,e}, o)
      {:DOWN, _ref, :process, _, :normal} ->
        e_value
    end
  end

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
  use GenServer

  def start(config, program) do
    GenServer.start(__MODULE__, {config, program, self()})
  end

  def init({config, program, parent}) do
    {:ok, {program, 0, parent}, {:continue, config}}
  end

  def handle_continue(config, {program, pointer, parent}) do
    {program, pointer} = run(program, pointer, config)
    {:noreply, {program, pointer, parent}}
  end

  def handle_info({:input, input}, {program, pointer, parent}) do
    {program, pointer} = run(program, pointer, input)
    {:noreply, {program, pointer, parent}}
  end

  def handle_info({:output, output}, {program, pointer, parent}) do
    send(parent, {:output, self(), output})
    {:noreply, {program, pointer, parent}}
  end

  def handle_info(:halt, state) do
    {:stop, :normal, state}
  end

  defp run(program, pointer, input) do
    exec(parse_ins(program[pointer]), program, pointer, input)
  end

  defp exec([99 | _], m, i, _input) do
    send(self(), :halt)
    {m, i}
  end

  defp exec([1, im1, im2, _], m, i, input) do
    {a, b, w} = {m[i+1], m[i+2], m[i+3]}
    run(%{m | w => (im1 && a || m[a]) + (im2 && b || m[b])}, i + 4, input)
  end

  defp exec([2, im1, im2, _], m, i, input) do
    {a, b, w} = {m[i+1], m[i+2], m[i+3]}
    run(%{m | w => (im1 && a || m[a]) * (im2 && b || m[b])}, i + 4, input)
  end

  defp exec([3 | _], m, i, nil) do
    {m, i}
  end

  defp exec([3 | _], m, i, input) do
    w = m[i+1]
    run(%{m | w => input}, i + 2, nil)
  end

  defp exec([4, im | _], m, i, nil) do
    output = im && m[i+1] || m[m[i+1]]
    send(self(), {:output, output})
    {m, i + 2}
  end

  defp exec([5, im1, im2, _], m, i, input) do
    condition = im1 && m[i+1] || m[m[i+1]]
    pointer = im2 && m[i+2] || m[m[i+2]]

    if condition != 0 do
      run(m, pointer, input)
    else
      run(m, i + 3, input)
    end
  end

  defp exec([6, im1, im2, _], m, i, input) do
    condition = im1 && m[i+1] || m[m[i+1]]
    pointer = im2 && m[i+2] || m[m[i+2]]

    if condition == 0 do
      run(m, pointer, input)
    else
      run(m, i + 3, input)
    end
  end

  defp exec([7, im1, im2, _], m, i, input) do
    p1 = im1 && m[i+1] || m[m[i+1]]
    p2 = im2 && m[i+2] || m[m[i+2]]
    w = m[i+3]

    if p1 < p2 do
      run(%{m | w => 1}, i + 4, input)
    else
      run(%{m | w => 0}, i + 4, input)
    end
  end

  defp exec([8, im1, im2, _], m, i, input) do
    p1 = im1 && m[i+1] || m[m[i+1]]
    p2 = im2 && m[i+2] || m[m[i+2]]
    w = m[i+3]

    if p1 == p2 do
      run(%{m | w => 1}, i + 4, input)
    else
      run(%{m | w => 0}, i + 4, input)
    end
  end

  defp parse_ins(ins) do
    {a, ins} =
      if ins > 10000 do
        {true, ins - 10000}
      else
        {false, ins}
      end
    {b, ins} =
      if ins > 1000 do
        {true, ins - 1000}
      else
        {false, ins}
      end
    {c, ins} =
      if ins > 100 do
        {true, ins - 100}
      else
        {false, ins}
      end
    op = ins

    [op, c, b, a]
  end
end

t = """
...MY_INPUT...
"""

program = L.parse_program(t)
[5,6,7,8,9] |> P.permutations |> Enum.map(&L.x(program, &1)) |> IO.inspect |> Enum.max |> IO.inspect
