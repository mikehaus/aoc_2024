# I could do a 90 deg transform of the board to save code but that's too much for now
# I could also do this with a graph, but I'll save that for later
defmodule Day6 do
  def solve() do
    {:ok, input} = File.read("puzzle.txt")

    grid =
      input
      |> String.split("\n", trim: true)

    grid_chars =
      grid
      |> Enum.map(&String.split(&1, "", trim: true))

    grid
    |> find_start_index()
    |> find_visited_indices(grid_chars, [], :up)
    |> List.flatten()
    |> Enum.chunk_every(2)
    |> Enum.uniq()
    |> Enum.count()
  end

  def find_start_index(input) do
    input
    |> Enum.with_index()
    |> Enum.map(fn {l, y_idx} ->
      l
      |> String.split("", trim: true)
      |> Enum.with_index()
      |> Enum.map(fn {val, x_idx} ->
        if val == "^" do
          [x_idx, y_idx]
        else
          nil
        end
      end)
    end)
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end


  def find_visited_indices([x, y], _grid, visited, _dir) when x == -1 or y == -1, do: visited

  def find_visited_indices([x, y], grid, visited, dir) do
    case validate_idx_oob([x, y], grid) do
      true -> [visited | [x, y]]
      _ -> find_visited_indices([x, y], grid, visited, dir, :cont)
    end
  end

  def validate_idx_oob([x, y], grid) do
    [h | _rest] = grid
    len_x = length(h)
    len_y = length(grid)

    x >= len_x - 1 || y >= len_y - 1
  end

  def find_visited_indices([x, y], grid, visited, :up, :cont) do
    next_char = Enum.at(Enum.at(grid, y - 1), x)

    case next_char do
      "#" -> go_right([right(x), y], grid, [visited | [x, y]])
      _ -> go_up([x, up(y)], grid, [visited | [x, y]])
    end
  end

  def find_visited_indices([x, y], grid, visited, :down, :cont) do
    next_char = Enum.at(Enum.at(grid, y + 1), x)

    case next_char do
      "#" -> go_left([left(x), y], grid, [visited | [x, y]])
      _ -> go_down([x, down(y)], grid, [visited | [x, y]])
    end
  end

  def find_visited_indices([x, y], grid, visited, :left, :cont) do
    next_char = Enum.at(Enum.at(grid, y), x - 1)

    case next_char do
      "#" -> go_up([x, up(y)], grid, [visited | [x, y]])
      _ -> go_left([left(x), y], grid, [visited | [x, y]])
    end
  end

  def find_visited_indices([x, y], grid, visited, :right, :cont) do
    next_char = Enum.at(Enum.at(grid, y), x + 1)

    case next_char do
      "#" -> go_down([x, down(y)], grid, [visited | [x, y]])
      _ -> go_right([right(x), y], grid, [visited | [x, y]])
    end
  end

  defp right(x), do: x + 1
  defp left(x), do: x - 1
  defp up(y), do: y - 1
  defp down(y), do: y + 1

  defp go_up(curr, grid, visited), do: find_visited_indices(curr, grid, visited, :up)
  defp go_down(curr, grid, visited), do: find_visited_indices(curr, grid, visited, :down)
  defp go_right(curr, grid, visited), do: find_visited_indices(curr, grid, visited, :right)
  defp go_left(curr, grid, visited), do: find_visited_indices(curr, grid, visited, :left)
end

Day6.solve()
