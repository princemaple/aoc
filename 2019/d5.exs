defmodule M do
  def x(t, input \\ []) do
    t
    |> String.trim
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.map(fn {v, k} -> {k, v} end)
    |> Enum.into(%{})
    |> z(0, input, [])
  end

  def z(m, i, input, output) do
    ins = m[i]

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

    exec([op, c, b, a], m, i + 1, input, output)
  end

  def exec([99 | _], _i, _m, _input, output) do
    Enum.reverse(output)
  end

  def exec([1, im1, im2, _], m, i, input, output) do
    {a, b, w} = {m[i], m[i+1], m[i+2]}
    z(%{m | w => (im1 && a || m[a]) + (im2 && b || m[b])}, i + 3, input, output)
  end

  def exec([2, im1, im2, _], m, i, input, output) do
    {a, b, w} = {m[i], m[i+1], m[i+2]}
    z(%{m | w => (im1 && a || m[a]) * (im2 && b || m[b])}, i + 3, input, output)
  end

  def exec([3 | _], m, i, [input | input_rest], output) do
    w = m[i]
    z(%{m | w => input}, i + 1, input_rest, output)
  end

  def exec([4, im | _], m, i, input, output) do
    out = im && m[i] || m[m[i]]
    z(m, i + 1, input, [out | output])
  end

  def exec([5, im1, im2, _], m, i, input, output) do
    condition = im1 && m[i] || m[m[i]]
    pointer = im2 && m[i+1] || m[m[i+1]]

    if condition != 0 do
      z(m, pointer, input, output)
    else
      z(m, i + 2, input, output)
    end
  end

  def exec([6, im1, im2, _], m, i, input, output) do
    condition = im1 && m[i] || m[m[i]]
    pointer = im2 && m[i+1] || m[m[i+1]]

    if condition == 0 do
      z(m, pointer, input, output)
    else
      z(m, i + 2, input, output)
    end
  end

  def exec([7, im1, im2, _], m, i, input, output) do
    p1 = im1 && m[i] || m[m[i]]
    p2 = im2 && m[i+1] || m[m[i+1]]
    w = m[i+2]

    if p1 < p2 do
      z(%{m | w => 1}, i + 3, input, output)
    else
      z(%{m | w => 0}, i + 3, input, output)
    end
  end

  def exec([8, im1, im2, _], m, i, input, output) do
    p1 = im1 && m[i] || m[m[i]]
    p2 = im2 && m[i+1] || m[m[i+1]]
    w = m[i+2]

    if p1 == p2 do
      z(%{m | w => 1}, i + 3, input, output)
    else
      z(%{m | w => 0}, i + 3, input, output)
    end
  end
end
