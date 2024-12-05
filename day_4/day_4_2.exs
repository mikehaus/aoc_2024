# My original approach was to create a functional transform pipeline like my pt_1
# After attempting this way, I found that it was overly verbose and hard to validate
# Using a few examples I found helped me to shape this result, primarily from
# https://github.com/bjorng/advent-of-code/blob/main/2024/day04/lib/day04.ex
defmodule WordSearch do
  @diag_directions [{-1, -1}, {-1, 1},
  {1, -1}, {1, 1}]

  def find_x_mas() do
    prep_for_parse()
    |> parse_input
    |> count_values
    |> IO.puts
  end

  def prep_for_parse() do
    {:ok, val} = File.read("wordsearch.txt")
    val
    |> String.trim()
    |> String.split()
  end

  defp parse_input(input) do
    input
    |> Enum.with_index
    |> Enum.flat_map(fn {line, row} ->
      String.to_charlist(line)
      |> Enum.with_index
      |> Enum.flat_map(fn {char, col} ->
        position = {row, col}
        [{position, char}]
      end)
    end)
    |> Map.new
  end

  defp count_values(grid) do
    Enum.reduce(grid, 0, fn {position, _}, n ->
      @diag_directions
      |> Enum.reduce(n, fn direction, n ->
        b = is_mas?(grid, position, direction) and
        is_mas?(grid, position, rotate90(direction))
        case b do
          true -> n + 1
          false -> n
        end
      end)
    end)
  end

  defp is_mas?(grid, position, direction) do
    at(grid, position) === ?A and
    at(grid, add(position, direction)) === ?M and
    at(grid, add(position, rotate180(direction))) === ?S
  end

  defp at(grid, position) do
    case grid do
      %{^position => c} -> c
      %{} -> nil
    end
  end

  defp add({a, b}, {c, d}), do: {a + c, b + d}

  defp rotate90({a, b}), do: {b, -a}

  defp rotate180({a, b}), do: {-a, -b}
end


WordSearch.find_x_mas()
