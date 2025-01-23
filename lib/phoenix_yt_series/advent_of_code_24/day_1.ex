defmodule PhoenixYtSeries.AdventOfCode24.Day1 do
  def parse(puzzle) do
    puzzle
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      [left, right] = String.split(row, "   ")
      {String.to_integer(left), String.to_integer(right)}
    end)
    |> Enum.unzip()
  end

  def part_1(puzzle) do
    {left, right} = parse(puzzle)

    left
    |> Enum.sort()
    |> Enum.zip(Enum.sort(right))
    |> Enum.reduce(0, fn {left, r}, acc ->
      acc + abs(left - r)
    end)
  end

  def part_2(puzzle) do
    {left, right} = parse(puzzle)
    freq = Enum.frequencies(right)

    Enum.reduce(left, 0, fn e, acc ->
      acc + e * Map.get(freq, e, 0)
    end)
  end
end
