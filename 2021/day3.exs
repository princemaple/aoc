# Title: Day3

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.split(["\r\n", "\n"], trim: true)
  |> Enum.map(fn line ->
    line
    |> String.split("", trim: true)
    |> Enum.map(fn b -> String.to_integer(b) end)
  end)

defmodule P1 do
  def calc(data) do
    data
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.map(fn %{0 => c0, 1 => c1} -> (c0 > c1 && 0) || 1 end)
    |> then(fn ns ->
      n1 = Integer.undigits(ns, 2)
      n2 = ns |> Enum.map(&(1 - &1)) |> Integer.undigits(2)
      n1 * n2
    end)
  end
end

P1.calc(data)

defmodule P2 do
  def calc(data) do
    data
    |> Enum.map(&List.to_tuple/1)
    |> then(fn ns ->
      n1 = ns |> filter(&Kernel.>/2, 0) |> Tuple.to_list() |> Integer.undigits(2)
      n2 = ns |> filter(&Kernel.<=/2, 0) |> Tuple.to_list() |> Integer.undigits(2)
      n1 * n2
    end)
  end

  def filter([line], _, _) do
    line
  end

  def filter(data, comp, index) do
    data
    |> Enum.map(&elem(&1, index))
    |> Enum.frequencies()
    |> IO.inspect()
    |> then(fn count -> (comp.(count[0], count[1]) && 0) || 1 end)
    |> then(fn b -> Enum.filter(data, &(elem(&1, index) == b)) end)
    |> then(fn data -> filter(data, comp, index + 1) end)
  end
end

P2.calc(data)
