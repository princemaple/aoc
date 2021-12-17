# Title: Day17

# ── P1 ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.trim_leading("target area: ")
  |> String.split(", ")
  |> then(fn ["x=" <> x_range, "y=" <> y_range] ->
    {x_range, []} = Code.eval_string(x_range)
    {y_range, []} = Code.eval_string(y_range)
    {x_range, y_range}
  end)

defmodule D17 do
  def calc({xmin..xmax = xr, ymin..ymax = yr}) do
    dxmin = 1..xmin |> Enum.find(&(Enum.sum(1..&1) >= xmin))

    Enum.reduce(dxmin..xmax, [], fn dx, acc ->
      Enum.reduce(ymin..200, acc, fn dy, acc ->
        Stream.iterate({{0, 0}, {dx, dy}}, fn {{x, y}, {dx, dy}} ->
          {{x + dx, y + dy}, {(dx > 0 && dx - 1) || ((dx < 0 && dx + 1) || dx), dy - 1}}
        end)
        |> Stream.drop_while(fn {{x, y}, {dx, dy}} ->
          (x < xmin and dx > 0) or y > ymax
        end)
        |> Stream.take_while(fn {{x, y}, _} ->
          x in xr and y in yr
        end)
        |> Enum.any?()
        |> if(do: [dy | acc], else: acc)
      end)
    end)
  end

  def solve1(data) do
    data
    |> Enum.max()
    |> then(fn h -> Enum.sum(1..h) end)
  end

  def solve2(data) do
    length(data)
  end
end

data
|> D17.calc()
|> D17.solve1()

data
|> D17.calc()
|> D17.solve2()
