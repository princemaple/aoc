# Title: Day1

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.split(["\r\n", "\n"], trim: true)
  |> Enum.map(&String.to_integer/1)
  |> tap(&IO.puts(length(&1)))

defmodule P1 do
  def count(data) do
    data
    |> Enum.zip(Enum.drop(data, 1))
    |> Enum.reduce(0, fn {prev, curr}, count ->
      if prev < curr, do: count + 1, else: count
    end)
  end
end

P1.count(data)

defmodule P2 do
  def count(data) do
    data =
      data
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.map(&Enum.sum/1)

    data
    |> Enum.zip(Enum.drop(data, 1))
    |> Enum.reduce(0, fn {prev, curr}, count ->
      if prev < curr, do: count + 1, else: count
    end)
  end
end

P2.count(data)
