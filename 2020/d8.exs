defmodule D8 do
  def parse(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [inst, int] -> {inst, String.to_integer(int)} end)
    |> Enum.with_index()
    |> Enum.map(fn {inst, index} -> {index, inst} end)
    |> Enum.into(%{})
  end

  def p1(program) do
    validate(program, {0, 0})
  end

  def p2(program) do
    to_be_flipped = Enum.filter(program, fn {_, {inst, _}} -> inst in ["jmp", "nop"] end)

    Enum.find_value(to_be_flipped, fn {index, {inst, int}} ->
      [inst] = ["jmp", "nop"] -- [inst]

      case validate(Map.put(program, index, {inst, int}), {0, 0}) do
        {:ok, acc} -> acc
        {:error, _acc} -> false
      end
    end)
  end

  def validate(program, {inst_index, acc}, cache \\ MapSet.new()) do
    cond do
      MapSet.member?(cache, inst_index) ->
        {:error, acc}

      inst_index == map_size(program) ->
        {:ok, acc}

      true ->
        {inc, acc} = exec_inst(program[inst_index], acc)
        validate(program, {inst_index + inc, acc}, MapSet.put(cache, inst_index))
    end
  end

  def exec_inst({"nop", _int}, acc) do
    {1, acc}
  end

  def exec_inst({"jmp", int}, acc) do
    {int, acc}
  end

  def exec_inst({"acc", int}, acc) do
    {1, acc + int}
  end
end
