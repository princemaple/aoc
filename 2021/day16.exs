# Title: Day12

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split("", trim: true)
  |> Enum.flat_map(
    &(&1
      |> String.to_integer(16)
      |> Integer.digits(2)
      |> then(fn l -> [0, 0, 0] ++ l end)
      |> Enum.take(-4))
  )

defmodule D16 do
  def parse(data) do
    if Enum.uniq(data) == [0] do
      {{[], []}, nil}
    else
      {data, %{}}
      |> parse_meta(:version)
      |> parse_meta(:type)
      |> parse_by_type()
    end
  end

  def parse_meta({[a, b, c | rest], meta}, meta_key) do
    {rest, Map.put(meta, meta_key, Integer.undigits([a, b, c], 2))}
  end

  def parse_by_type({data, %{type: 4} = meta}) do
    {literal, rest} = parse_literal(data)
    {{Integer.undigits(literal, 2), rest}, meta}
  end

  def parse_by_type({data, meta}) do
    {parse_operator(data), meta}
  end

  def parse_literal([1, a, b, c, d | rest]) do
    {data, rest} = parse_literal(rest)
    {[a, b, c, d] ++ data, rest}
  end

  def parse_literal([0, a, b, c, d | rest]) do
    {[a, b, c, d], rest}
  end

  def parse_operator([0 | rest]) do
    {length, rest} = Enum.split(rest, 15)
    {payload, rest} = Enum.split(rest, Integer.undigits(length, 2))
    {parse_sub(payload), rest}
  end

  def parse_operator([1 | rest]) do
    {length, payload} = Enum.split(rest, 11)
    {data, [rest]} = Enum.split(parse_sub(payload, Integer.undigits(length, 2)), -1)
    {data, rest}
  end

  def parse_sub([]), do: []

  def parse_sub(data) do
    {{data, rest}, meta} = parse(data)
    [{{data, []}, meta} | parse_sub(rest)]
  end

  def parse_sub(rest, 0), do: [rest]

  def parse_sub(data, n) do
    {{data, rest}, meta} = parse(data)
    [{{data, []}, meta} | parse_sub(rest, n - 1)]
  end

  def solve1({{data, _rest}, meta}) when is_list(data) do
    meta.version + (data |> Enum.map(&solve1/1) |> Enum.sum())
  end

  def solve1({{_data, _rest}, meta}) do
    meta.version
  end

  def solve2({{data, _}, %{type: 0}}) do
    data |> Enum.map(&solve2/1) |> Enum.sum()
  end

  def solve2({{data, _}, %{type: 1}}) do
    data |> Enum.map(&solve2/1) |> Enum.product()
  end

  def solve2({{data, _}, %{type: 2}}) do
    data |> Enum.map(&solve2/1) |> Enum.min()
  end

  def solve2({{data, _}, %{type: 3}}) do
    data |> Enum.map(&solve2/1) |> Enum.max()
  end

  def solve2({{data, _}, %{type: 4}}) do
    data
  end

  def solve2({{data, _}, %{type: 5}}) do
    data
    |> Enum.map(&solve2/1)
    |> then(fn [a, b] -> (a > b && 1) || 0 end)
  end

  def solve2({{data, _}, %{type: 6}}) do
    data
    |> Enum.map(&solve2/1)
    |> then(fn [a, b] -> (a < b && 1) || 0 end)
  end

  def solve2({{data, _}, %{type: 7}}) do
    data
    |> Enum.map(&solve2/1)
    |> then(fn [a, b] -> (a == b && 1) || 0 end)
  end
end

data
|> D16.parse()
|> D16.solve1()

data
|> D16.parse()
|> D16.solve2()
