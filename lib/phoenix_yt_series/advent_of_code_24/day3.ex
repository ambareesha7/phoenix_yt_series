defmodule PhoenixYtSeries.AdventOfCode24.Day3 do
  def part1(input) do
    ~r/mul\((\d{1,3})\,(\d{1,3})\)/
    |> Regex.scan(input, capture: :all_but_first)
    |> IO.inspect()
    |> Enum.map(&do_mul/1)
    |> Enum.sum()
  end

  def part2(input) do
    ~r/(mul\((\d{1,3})\,(\d{1,3})\)|do\(\)|don\'t\(\))/
    |> Regex.scan(input, capture: :all_but_first)
    |> handle(:enabled)
    |> Enum.sum()
  end

  defp do_mul([a, b]), do: do_mul(a, b)
  defp do_mul(a, b), do: String.to_integer(a) * String.to_integer(b)

  defp handle([["don't()"] | tail], :enabled),
    do: handle(tail, :disabled)

  defp handle([["do()"] | tail], :disabled),
    do: handle(tail, :enabled)

  defp handle([[_, a, b] | tail], :enabled),
    do: [do_mul(a, b) | handle(tail, :enabled)]

  defp handle([_ | tail], status),
    do: handle(tail, status)

  defp handle([], _status),
    do: []
end
