defmodule M do
  def x(t) do
    [min, max] = t |> String.split("-") |> Enum.map(&String.to_integer/1)

    for x <- min..max do
      ds = Integer.digits(x)
      if asc(ds) and double(ds, 0) do
        true
      end
    end
    |> Enum.count(& &1)
    # |> Enum.filter(& &1)
  end

  defp asc(ds) do
    ds
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(true, fn [a, b], acc -> a <= b && acc end)
  end

  defp double([a, a], 0) do
    true
  end

  defp double([a, a | r], c) do
    double([a | r], c + 1)
  end

  defp double([_ | ([_ | _] = r)], 1) do
    true
  end

  defp double([_ | ([_ | _] = r)], _) do
    double(r, 0)
  end

  defp double(_, _) do
    false
  end
end
