# Title: Day4

# ── Untitled ──

numbers =
  "input"
  |> IO.gets()
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)
  |> IO.inspect()

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.split(["\r\n", "\n"], trim: true)
  |> Enum.chunk_every(5)
  |> Enum.map(fn rows ->
    Enum.map(rows, fn row ->
      row
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end)

boards =
  for board <- data do
    for {row, ri} <- Enum.with_index(board) do
      for {col, ci} <- Enum.with_index(row) do
        {col, {ri, ci}}
      end
    end
    |> List.flatten()
    |> Map.new()
    |> then(&{&1, MapSet.new(), MapSet.new()})
  end

defmodule P1 do
  def calc(boards, [n | numbers]) do
    boards =
      Enum.map(boards, fn {map, coords, ns} = original ->
        if where = Map.get(map, n) do
          {map, MapSet.put(coords, where), MapSet.put(ns, n)}
        else
          original
        end
      end)

    if winner =
         Enum.find(boards, fn {_map, coords, _} ->
           [Enum.group_by(coords, &elem(&1, 0)), Enum.group_by(coords, &elem(&1, 1))]
           |> Enum.any?(fn map ->
             Enum.any?(map, fn {_, v} -> length(v) == 5 end)
           end)
         end) do
      {map, _, ns} = winner

      map
      |> Map.keys()
      |> Kernel.--(ns |> Enum.to_list() |> IO.inspect(label: "ns"))
      |> Enum.sum()
      |> IO.inspect(label: "sum")
      |> Kernel.*(n)
    else
      calc(boards, numbers)
    end
  end
end

P1.calc(boards, numbers)

defmodule P2 do
  def calc(boards, [n | numbers]) do
    boards =
      Enum.map(boards, fn {map, coords, ns} = original ->
        if where = Map.get(map, n) do
          {map, MapSet.put(coords, where), MapSet.put(ns, n)}
        else
          original
        end
      end)

    winners =
      Enum.filter(boards, fn {_map, coords, _} ->
        [Enum.group_by(coords, &elem(&1, 0)), Enum.group_by(coords, &elem(&1, 1))]
        |> Enum.any?(fn map ->
          Enum.any?(map, fn {_, v} -> length(v) == 5 end)
        end)
      end)

    if match?(^winners, boards) do
      {map, _, ns} = List.first(boards)

      map
      |> Map.keys()
      |> Kernel.--(ns |> Enum.to_list() |> IO.inspect(label: "ns"))
      |> Enum.sum()
      |> IO.inspect(label: "sum")
      |> Kernel.*(n)
    else
      calc(boards -- winners, numbers)
    end
  end
end

P2.calc(boards, numbers)
