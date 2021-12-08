# Title: Day8

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&(&1 |> String.split([" ", " | "]) |> Enum.split(10)))

defmodule P1 do
  def calc(data) do
    data
    |> Enum.map(fn {_, output} ->
      output
    end)
    |> List.flatten()
    |> Enum.filter(&(String.length(&1) in [2, 3, 4, 7]))
    |> length
  end
end

P1.calc(data)

defmodule P2 do
  def calc(data) do
    data
    |> Enum.map(fn {input, output} ->
      input
      |> Enum.map(fn number ->
        number
        |> String.split("", trim: true)
      end)
      |> Enum.group_by(&length/1)
      |> then(fn map ->
        one = List.first(map[2])
        seven = List.first(map[3])
        four = List.first(map[4])
        eight = List.first(map[7])

        three = Enum.find(map[5], &(length(&1 -- one) == 3))
        five = Enum.find(map[5] -- [three], &(length(&1 -- four) == 2))
        two = List.first(map[5] -- [three, five])

        nine = Enum.find(map[6], &(length(&1 -- three) == 1))
        six = Enum.find(map[6] -- [nine], &(length(&1 -- one) == 5))
        zero = List.first(map[6] -- [nine, six])

        [zero, one, two, three, four, five, six, seven, eight, nine]
        |> Enum.map(&Enum.sort/1)
        |> Enum.zip(0..9)
        |> Enum.into(%{})
      end)
      |> then(fn lookup ->
        output
        |> Enum.map(fn number ->
          number
          |> String.split("", trim: true)
          |> Enum.sort()
        end)
        |> Enum.map(&Map.fetch!(lookup, &1))
      end)
    end)
    |> Enum.map(&Integer.undigits/1)
    |> Enum.sum()
  end
end

P2.calc(data)
