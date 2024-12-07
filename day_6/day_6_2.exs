defmodule Day6 do
  def solve() do
    {:ok, input} = File.read("test.txt")

    grid =
      input
      |> String.split("\n", trim: true)

    grid_chars =
      grid
      |> Enum.map(&String.split(&1, "", trim: true))

    grid
    |> find_start_index()
    |> traverse(grid_chars, [], 0, :up)
    |> IO.inspect(label: "DEBUG")
    |> List.flatten()
    |> Enum.chunk_every(2)
    |> Enum.uniq()
    |> Enum.count()
    |> IO.inspect(label: "DEBUG")
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

  def traverse([x, y], grid, visited, count, dir) do
    IO.inspect(count)
    cond do
      oob?([x, y], grid) -> count
      true ->
        new_grid = replace_char([x, y], grid, "#", dir)
        extra = cycle?([x, y], [x, y], 0, new_grid, dir, dir)
        traverse([x, y], grid, visited, count + extra, dir, :cont)
        count
    end
  end

  def traverse([x, y], grid, visited, count, :up, :cont) do
    next_char = Enum.at(Enum.at(grid, y - 1), x)

    case next_char do
      "#" -> go_right([right(x), y], grid, [visited | [x, y]], count)
      _ -> go_up([x, up(y)], grid, [visited | [x, y]], count)
    end
  end

  def traverse([x, y], grid, visited, count, :down, :cont) do
    next_char = Enum.at(Enum.at(grid, y + 1), x)

    case next_char do
      "#" -> go_left([left(x), y], grid, [visited | [x, y]], count)
      _ -> go_down([x, down(y)], grid, [visited | [x, y]], count)
    end
  end

  def traverse([x, y], grid, visited, count, :left, :cont) do
    next_char = Enum.at(Enum.at(grid, y), x - 1)

    case next_char do
      "#" -> go_up([x, up(y)], grid, [visited | [x, y]], count)
      _ -> go_left([left(x), y], grid, [visited | [x, y]], count)
    end
  end

  def traverse([x, y], grid, visited, count, :right, :cont) do
    next_char = Enum.at(Enum.at(grid, y), x + 1)

    case next_char do
      "#" -> go_down([x, down(y)], grid, [visited | [x, y]], count)
      _ -> go_right([right(x), y], grid, [visited | [x, y]], count)
    end
  end

  def cycle?(fast, slow, itr, grid, fast_dir \\ :up, slow_dir \\ :up) do
    IO.inspect({fast, "FAST"})
    IO.inspect({slow, "SLOW"})
    cond do
      oob?(fast, grid) ->
        0

      fast == slow && itr > 0 ->
        1

      true ->
        IO.inspect("got here 1")
        # TODO: THIS IS WHERE THE ERROR IS
        {next_fast, next_fast_dir} = Coordinates.next(fast, grid, :fast, fast_dir)
        {next_slow, next_slow_dir} = Coordinates.next(slow, grid, :slow, slow_dir)
        cycle?(next_fast, next_slow, itr + 1, grid, next_fast_dir, next_slow_dir)
    end
  end

  defp replace_char([x, y], grid, val, :up), do: replace_char([x, up(y)], grid, val)
  defp replace_char([x, y], grid, val, :down), do: replace_char([x, down(y)], grid, val)
  defp replace_char([x, y], grid, val, :left), do: replace_char([left(x), y], grid, val)
  defp replace_char([x, y], grid, val, :right), do: replace_char([right(x), y], grid, val)

  defp replace_char([x, y], grid, val) do
    replacement =
      grid
      |> Enum.at(y)
      |> Enum.with_index()
      |> Enum.map(fn {char, idx} -> if idx == x, do: val, else: char end)
      |> IO.inspect(label: "DEBUG")

    grid
    |> Enum.with_index()
    # |> IO.inspect(label: "DEBUG")
    |> Enum.map(fn {l, idx} -> if idx == y, do: replacement, else: l end)
  end

  defp oob?([x, y], grid), do: x <= -1 or y <= -1 or oob_wide?([x, y], grid)

  defp oob_wide?([x, y], grid) do
    IO.puts("GOT HERE")
    IO.inspect(grid)
    [h | _rest] = grid
    len_x = length(h)
    len_y = length(grid)

    x >= len_x - 1 || y >= len_y - 1
  end

  defp right(x), do: x + 1
  defp left(x), do: x - 1
  defp up(y), do: y - 1
  defp down(y), do: y + 1

  defp go_up(curr, grid, visited, count), do: traverse(curr, grid, visited, count, :up)
  defp go_down(curr, grid, visited, count), do: traverse(curr, grid, visited, count, :down)
  defp go_right(curr, grid, visited, count), do: traverse(curr, grid, visited, count, :right)
  defp go_left(curr, grid, visited, count), do: traverse(curr, grid, visited, count, :left)
end

defmodule Coordinates do
  def next([x, y], grid, :fast, :up) do
    next_char_fast = Enum.at(Enum.at(grid, fast_up(y)), x)
    next_char_slow = Enum.at(Enum.at(grid, slow_up(y)), x)

    cond do
      next_char_fast == ?# -> {[slow_right(x), slow_up(y)], :up}
      next_char_slow == ?# -> {[fast_right(x), y], :right}
      true -> {[x, fast_up(y)], :up}
    end
  end

  def next([x, y], grid, :slow, :up) do
    next_char = Enum.at(Enum.at(grid, slow_up(y)), x)

    case next_char do
      ?# -> {[slow_right(x), y], :right}
      _ -> {[x, slow_up(y)], :up}
    end
  end

  def next([x, y], grid, :fast, :down) do
    next_char_fast = Enum.at(Enum.at(grid, fast_down(y)), x)
    next_char_slow = Enum.at(Enum.at(grid, slow_down(y)), x)

    cond do
      next_char_fast == ?# -> {[slow_left(x), slow_down(y)], :left}
      next_char_slow == ?# -> {[fast_left(x), y], :left}
      true -> {[x, fast_down(y)], :down}
    end
  end

  def next([x, y], grid, :slow, :down) do
    next_char = Enum.at(Enum.at(grid, slow_down(y)), x)

    case next_char do
      ?# -> {[slow_left(x), y], :left}
      _ -> {[x, slow_down(y)], :down}
    end
  end

  def next([x, y], grid, :fast, :left) do
    next_char_fast = Enum.at(Enum.at(grid, y), fast_left(x))
    next_char_slow = Enum.at(Enum.at(grid, y), slow_left(x))

    cond do
      next_char_fast == ?# -> {[slow_left(x), slow_up(y)], :up}
      next_char_slow == ?# -> {[x, fast_up(y)], :up}
      true -> {[fast_left(x), y], :left}
    end
  end

  def next([x, y], grid, :slow, :left) do
    next_char = Enum.at(Enum.at(grid, y), slow_left(x))

    case next_char do
      ?# -> {[x, slow_up(y)], :up}
      _ -> {[slow_left(x), y], :left}
    end
  end

  def next([x, y], grid, :fast, :right) do
    next_char_fast = Enum.at(Enum.at(grid, y), fast_right(x))
    next_char_slow = Enum.at(Enum.at(grid, y), slow_right(x))

    cond do
      next_char_fast == ?# -> {[slow_right(x), slow_down(y)], :down}
      next_char_slow == ?# -> {[x, fast_down(y)], :down}
      true -> {[fast_right(x), y], :right}
    end
  end

  def next([x, y], grid, :slow, :right) do
    next_char = Enum.at(Enum.at(grid, y), slow_right(x))

    case next_char do
      ?# -> {[x, slow_down(y)], :down}
      _ -> {[slow_right(x), y], :right}
    end
  end

  defp slow_right(x), do: x + 1
  defp slow_left(x), do: x - 1
  defp slow_up(y), do: y - 1
  defp slow_down(y), do: y + 1

  defp fast_right(x), do: x + 2
  defp fast_left(x), do: x - 2
  defp fast_up(y), do: y - 2
  defp fast_down(y), do: y + 2
end

Day6.solve()
