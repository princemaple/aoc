# Title: Day18

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&(&1 |> Code.eval_string() |> elem(0)))

defmodule D18 do
  def add(a, b) do
    reduce([a, b])
  end

  def reduce(l) do
    cond do
      l = explode(l, _level = 1) ->
        {_, l, _} = l
        # IO.inspect(l, charlists: false, label: "after explode")
        reduce(l)

      l = split(l) ->
        # IO.inspect(l, charlists: false, label: "after split")
        reduce(l)

      true ->
        l
    end
  end

  def merge([a, b], n) do
    [a, merge(b, n)]
  end

  def merge(n, [a, b]) do
    [merge(n, a), b]
  end

  def merge(a, b) do
    a + b
  end

  def explode([a, b], 5) do
    # IO.inspect([a,b], label: "explode")
    {a, 0, b}
  end

  def explode([a, b], level) do
    with {aa, n, ab} <- explode(a, level + 1) do
      {aa, [n, merge(ab, b)], 0}
    end ||
      with {ba, n, bb} <- explode(b, level + 1) do
        {0, [merge(a, ba), n], bb}
      end
  end

  def explode(_n, _level) do
    false
  end

  def split([a, b]) do
    if aa = split(a) do
      [aa, b]
    else
      if bb = split(b) do
        [a, bb]
      else
        false
      end
    end
  end

  def split(n) when n >= 10 do
    # IO.inspect(n, label: "split")
    half = div(n, 2)
    [half, n - half]
  end

  def split(n) do
    false
  end

  def magnitude([a, b]) when is_integer(a) and is_integer(b) do
    3 * a + 2 * b
  end

  def magnitude([a, b]) when is_integer(a) do
    magnitude([a, magnitude(b)])
  end

  def magnitude([a, b]) when is_integer(b) do
    magnitude([magnitude(a), b])
  end

  def magnitude([a, b]) do
    magnitude([magnitude(a), magnitude(b)])
  end
end

# ── P1 ──

data
|> Enum.reduce(&IO.inspect(D18.add(&2, &1), charlists: false))
|> D18.magnitude()

# ── P2 ──

for a <- data, b <- data, a != b do
  [
    D18.magnitude(D18.add(a, b)),
    D18.magnitude(D18.add(b, a))
  ]
end
|> List.flatten()
|> Enum.max()
