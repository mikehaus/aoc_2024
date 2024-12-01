# I need to sort each list and sum up the differences
defmodule DayOne do
  def read_file do
    File.stream!("day1.txt")
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, _index} -> split_line(line) end)
    |> Stream.with_index()
    |> reduce_stream_into_value()

    # |> Stream.run()
  end

  # I need to get each into an array
  def split_line(line) do
    line
    |> String.split(~r/\s+/, trim: true)
  end

  def reduce_stream_into_value(stream) do
    stream
    |> reduce_into_alternating_arrays()
    |> sort_list_tuple()
    |> zip_lists()
    |> sum_total
  end

  def reduce_into_alternating_arrays(
    stream
  ) do
    stream |> Enum.reduce({[], []}, fn {element, index}, {list1, list2} ->
      if rem(index, 2) == 0 do
        {[element | list1], list2}
      else
        {list1, [element | list2]}
      end
    end)
  end

  def sort_list_tuple({l1, l2}), do: {Enum.sort(l1), Enum.sort(l2)}

  def zip_lists({l1, l2}) do
    l1
    |> Enum.zip(l2)
    |> Enum.map(fn {a, b} -> abs(String.to_integer(b) - String.to_integer(a)) end)
  end

  def sum_total(l) do
    Enum.sum(l)
    |> IO.inspect(label: "DEBUG")
  end
end

DayOne.read_file()
