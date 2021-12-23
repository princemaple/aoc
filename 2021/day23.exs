data =
  """
  #############
  #...........#
  ###B#B#D#A###
    #C#A#D#C#
    #########
  """
  |> String.trim()
  |> String.split(["\r\n", "\n"], trim: true)
  |> then(fn [_, dots, row1, row2, _] ->
    ((Regex.scan(~r/\./, dots, return: :index)
      |> Enum.map(fn [{i, _}] -> {{0, i}, nil} end)) ++
       (Regex.scan(~r/[A-D]/, row1)
        |> Enum.zip([3, 5, 7, 9])
        |> Enum.map(fn {[x], i} -> {{1, i}, {x, false}} end)) ++
       (Regex.scan(~r/[A-D]/, row2)
        |> Enum.zip([3, 5, 7, 9])
        |> Enum.map(fn {[x], i} -> {{2, i}, {x, false}} end))) --
      ([3, 5, 7, 9]
       |> Enum.map(fn i -> {{0, i}, nil} end))
  end)
  |> Map.new()
  |> Map.update!({2, 3}, fn {t, _} -> {t, t == "A"} end)
  |> Map.update!({2, 5}, fn {t, _} -> {t, t == "B"} end)
  |> Map.update!({2, 7}, fn {t, _} -> {t, t == "C"} end)
  |> Map.update!({2, 9}, fn {t, _} -> {t, t == "D"} end)

defmodule D23 do
  @weight %{"A" => 1, "B" => 10, "C" => 100, "D" => 1000}

  def search(map, cost, seen, path) do
    shrimps = Enum.reject(map, &is_nil(elem(&1, 1)))
    shrimps_tuple = shrimps |> Enum.sort() |> List.to_tuple()
    all_done? = Enum.all?(shrimps, &match?({_, {_, true}}, &1))

    cond do
      all_done? ->
        if {map[{2, 3}], map[{2, 5}], map[{2, 7}], map[{2, 9}]} ==
             {{"A", true}, {"B", true}, {"C", true}, {"D", true}} do
          {seen, cost}
        else
          {seen, :infinity}
        end

      (found = seen[shrimps_tuple]) && elem(found, 0) <= cost ->
        {seen, seen[shrimps_tuple]}

      true ->
        hallway = Enum.filter(map, &match?({{0, _}, _}, &1))

        out_options =
          shrimps
          |> Enum.filter(fn {{row, col}, {_type, done?}} ->
            not done? && (row == 1 or (row == 2 && is_nil(map[{1, col}])))
          end)
          |> Enum.map(fn {{_row, col} = coords, {type, _done?}} ->
            {{coords, {type, false}},
             Enum.filter(hallway, fn
               {{_, hw_col}, nil} -> Enum.all?(hw_col..col, &(!map[{0, &1}]))
               _ -> false
             end)}
          end)

        in_options =
          shrimps
          |> Enum.filter(fn {{row, _col}, {_type, _done?}} -> row == 0 end)
          |> Enum.map(fn {{_row, col} = coords, {type, _done?}} ->
            {{coords, {type, true}},
             [3, 5, 7, 9]
             |> Enum.map(fn rm_col ->
               deep = map[{2, rm_col}]
               shallow = map[{1, rm_col}]

               if is_nil(deep) do
                 {2, rm_col}
               else
                 if elem(deep, 0) == type and is_nil(shallow) do
                   {1, rm_col}
                 end
               end
               |> then(fn
                 nil ->
                   false

                 other ->
                   Enum.count_until(rm_col..col, &map[{0, &1}], 2) == 1 && {other, nil}
               end)
             end)
             |> Enum.filter(& &1)}
          end)

        (out_options ++ in_options)
        |> Stream.flat_map(fn {s, l} -> Stream.map(l, fn x -> {s, x} end) end)
        |> Enum.reduce({seen, :infinity}, fn
          {{{from_row, from_col} = from, {type, _done?} = shrimp}, {{to_row, to_col} = to, _}},
          {seen, min_cost} ->
            {seen, route_cost} =
              search(
                map |> Map.put(from, nil) |> Map.put(to, shrimp),
                @weight[type] * (abs(from_row - to_row) + abs(from_col - to_col)) + cost,
                seen,
                [{type, from, to} | path]
              )

            {seen, min(min_cost, route_cost)}
        end)
        |> then(fn {seen, min_cost} ->
          {Map.put(seen, shrimps_tuple, {cost, min_cost}), min_cost}
        end)
    end
  end
end

map = data

for row <- 0..2 do
  for col <- 1..11 do
    case Map.get(map, {row, col}, " ") do
      {type, _} -> type
      nil -> "."
      " " -> "_"
    end
  end
  |> IO.puts()
end

IO.inspect(D23.search(map, 0, %{}, []) |> elem(1))
