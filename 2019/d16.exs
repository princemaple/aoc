defmodule D16 do
  def parse(t) do
    t
    |> String.to_integer
    |> Integer.digits
  end

  def solve1(input_text, base_pattern, phase) do
    input = D16.parse(input_text)
    input_length = length(input)

    patterns =
      input
      |> Enum.with_index(1)
      |> Enum.map(fn {_, repeat_count} ->
        base_pattern
        |> Enum.map(fn digit -> Stream.cycle([digit]) |> Stream.take(repeat_count) end)
        |> Stream.concat
        |> Enum.take(input_length + 1)
        |> Stream.cycle
        |> Stream.drop(1)
      end)

    1..phase
    |> Enum.reduce(input, fn _, acc ->
      do_solve1(acc, patterns)
    end)
    |> Enum.take(8)
    |> Enum.join("")
  end

  def do_solve1(input, patterns) do
    input
    |> Stream.zip(patterns)
    |> Enum.map(fn {_, pattern} ->
      input
      |> Stream.zip(pattern)
      |> Stream.map(fn {x, y} -> x * y end)
      |> Enum.sum
      |> abs
      |> Integer.mod(10)
    end)
  end

  def solve2(input_text) do
    input = parse(input_text)
    input = 1..10000 |> Stream.flat_map(fn _ -> input end)
    offset = input |> Enum.take(7) |> Integer.undigits
    input = input |> Enum.drop(offset)

    1..100
    |> Enum.reduce(input, fn _, input -> do_solve2(input) end)
    |> Enum.take(8)
    |> Enum.map(&to_string/1)
    |> Enum.join("")
  end

  def do_solve2(input) do
    sum = input |> Enum.sum

    {0, numbers} =
      Enum.reduce(input, {sum, []}, fn n, {sum, acc} ->
        {sum - n, [Integer.mod(sum, 10) | acc]}
      end)

    numbers |> Enum.reverse
  end
end

t = "59790132880344516900093091154955597199863490073342910249565395038806135885706290664499164028251508292041959926849162473699550018653393834944216172810195882161876866188294352485183178740261279280213486011018791012560046012995409807741782162189252951939029564062935408459914894373210511494699108265315264830173403743547300700976944780004513514866386570658448247527151658945604790687693036691590606045331434271899594734825392560698221510565391059565109571638751133487824774572142934078485772422422132834305704887084146829228294925039109858598295988853017494057928948890390543290199918610303090142501490713145935617325806587528883833726972378426243439037"

# t1 = "12345678"

# t2 = "80871224585914546619083218645595"
# t3 = "19617804207202209144916044189917"
# t4 = "69317163492948606335995924319873"

# t1 |> D16.solve1([0, 1, 0, -1], 4) |> IO.puts
# t2 |> D16.solve1([0, 1, 0, -1], 100) |> IO.puts
# t3 |> D16.solve1([0, 1, 0, -1], 100) |> IO.puts
# t4 |> D16.solve1([0, 1, 0, -1], 100) |> IO.puts

# t |> D16.solve1([0, 1, 0, -1], 100) |> IO.puts

t |> D16.solve2() |> IO.puts
