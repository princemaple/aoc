t = [14, 8, 16, 0, 1, 17]

defmodule D15 do
  def solve(data, count) do
    Stream.iterate(
      {data
       |> Enum.with_index(1)
       |> Enum.into(%{}), 0, length(data) + 1},
      fn {history, next, turn} ->
        v =
           if prev = history[next] do
            turn - prev
          else
            0
          end

        {Map.put(history, next, turn), v, turn + 1}
      end
    )
    |> Enum.at(count - length(data) - 1)
    |> elem(1)
  end
end

# t1 =
#   [
#     # [0, 3, 6],
#     [1, 3, 2],
#     [2, 1, 3],
#     [1, 2, 3],
#     [2, 3, 1],
#     [3, 2, 1],
#     [3, 1, 2]
#   ]
#   |> Enum.map(&D15.solve(&1, 2020))
#   |> IO.inspect()

IO.inspect D15.solve(t, 2020)
IO.inspect D15.solve(t, 30000000)
