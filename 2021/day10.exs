# Title: Day10

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&(&1 |> String.split("", trim: true)))

defmodule P1 do
  @lookup %{")" => 3, "]" => 57, "}" => 1197, ">" => 25137}

  def calc(data) do
    data
    |> Enum.map(fn line ->
      Enum.reduce_while(line, [], fn
        "]", ["[" | rest] -> {:cont, rest}
        ">", ["<" | rest] -> {:cont, rest}
        ")", ["(" | rest] -> {:cont, rest}
        "}", ["{" | rest] -> {:cont, rest}
        open, rest when open in ~w|( [ { <| -> {:cont, [open | rest]}
        mismatch, _ -> {:halt, mismatch}
      end)
    end)
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&Map.fetch!(@lookup, &1))
    |> Enum.sum()
  end
end

P1.calc(data)

defmodule P2 do
  @lookup %{")" => 1, "]" => 2, "}" => 3, ">" => 4}

  def calc(data) do
    data
    |> Enum.map(fn line ->
      Enum.reduce_while(line, [], fn
        "]", ["[" | rest] -> {:cont, rest}
        ">", ["<" | rest] -> {:cont, rest}
        ")", ["(" | rest] -> {:cont, rest}
        "}", ["{" | rest] -> {:cont, rest}
        open, rest when open in ~w|( [ { <| -> {:cont, [open | rest]}
        mismatch, _ -> {:halt, mismatch}
      end)
    end)
    |> Enum.reject(&is_binary/1)
    |> Enum.map(fn line ->
      Enum.reduce(line, [], fn
        "[", acc -> ["]" | acc]
        "<", acc -> [">" | acc]
        "(", acc -> [")" | acc]
        "{", acc -> ["}" | acc]
      end)
      |> Enum.reverse()
      |> Enum.reduce(0, fn bracket, sum ->
        sum * 5 + Map.fetch!(@lookup, bracket)
      end)
    end)
    |> Enum.sort()
    |> then(fn scores ->
      Enum.at(scores, scores |> length |> div(2))
    end)
  end
end

P2.calc(data)