t = """
1000067
17,x,x,x,x,x,x,x,x,x,x,37,x,x,x,x,x,439,x,29,x,x,x,x,x,x,x,x,x,x,13,x,x,x,x,x,x,x,x,x,23,x,x,x,x,x,x,x,787,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,19
"""

defmodule D13 do
  def parse1(text) do
    [t_start, ts] = String.split(text, "\n", trim: true)
    ts = String.split(ts, ",")
    t_start = String.to_integer(t_start)

    ts =
      ts
      |> Enum.map(fn
        "x" -> []
        t -> String.to_integer(t)
      end)
      |> List.flatten()

    {t_start, ts}
  end

  def p1({t_start, ts}) do
    ts
    |> Enum.map(fn t ->
      {t, t - rem(t_start, t)}
    end)
    |> Enum.min_by(&elem(&1, 1))
  end

  def parse2(text) do
    [_, ts] = String.split(text, "\n", trim: true)

    ts
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.reject(&(elem(&1, 0) == "x"))
  end

  def p2(data) do
    data
    |> Enum.map(&"(x + #{elem(&1, 1)}) mod #{elem(&1, 0)} = 0")
    |> Enum.join("; ")
  end
end

t |> D13.parse1() |> D13.p1() |> IO.inspect()
t |> D13.parse2() |> IO.inspect() |> D13.p2() |> IO.inspect()
