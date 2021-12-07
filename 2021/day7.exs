# Title: Day7

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(",", trim: true)
  |> Enum.map(&String.to_integer/1)

defmodule P1 do
  def calc(data) do
    data
    |> Enum.frequencies()
    |> then(fn map ->
      for key <- Map.keys(map), into: %{} do
        {key,
         for {k, v} <- map do
           abs(k - key) * v
         end
         |> Enum.sum()}
      end
    end)
    |> Enum.min_by(&elem(&1, 1))
  end
end

P1.calc(data)

defmodule P2 do
  def calc(data) do
    data
    |> Enum.frequencies()
    |> then(fn map ->
      for key <- 0..Enum.max(Map.keys(map)), into: %{} do
        {key,
         for {k, v} <- map do
           Enum.sum(1..abs(k - key)) * v
         end
         |> Enum.sum()}
      end
    end)
    |> Enum.min_by(&elem(&1, 1))
  end
end

P2.calc(data)
