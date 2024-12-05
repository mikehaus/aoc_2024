# There is definitely repeat work here, but I didn't have time today to reduce duplicate work
# Provided more time, I would have refined this to eliminate duplicate transforms
# This is more of a brute force approach
defmodule WordSearch do
  @word "XMAS"

  def read_file do
    File.stream!("wordsearch.txt")
    |> Stream.map(& &1)
    |> Enum.map(&String.trim(&1))
    |> find_word_count()
  end

  # Given a list of strings, find count of word "XMAS"
  defp find_word_count(list) do
    horizontal_count =
      list
      |> Enum.flat_map(fn val -> create_horizontal_words(val) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    reverse_horizontal_count =
      list
      |> Enum.flat_map(fn val -> create_horizontal_words(val) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(fn word -> String.reverse(word) end)
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    vertical_count =
      list
      |> Enum.with_index()
      |> Enum.map(fn {_word, i} -> create_vertical_word_columns(list, i) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(&generate_vertical_words(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    reverse_vertical_count =
      list
      |> Enum.with_index()
      |> Enum.map(fn {_word, i} -> create_vertical_word_columns(list, i) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(&generate_vertical_words(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.map(&String.reverse/1)
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    diagonal_count =
      list
      |> Enum.with_index()
      |> Enum.map(fn {_word, i} -> create_vertical_word_columns(list, i) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(&generate_diagonal_words(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    reverse_diagonal_count =
      list
      |> Enum.with_index()
      |> Enum.map(fn {_word, i} -> create_vertical_word_columns(list, i) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(&generate_diagonal_words(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.map(&String.reverse/1)
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    inverse_diagonal_count =
      list
      |> Enum.with_index()
      |> Enum.map(fn {_word, i} -> create_vertical_word_columns(list, i) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(&generate_inverse_diagonal_words(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    reverse_inverse_diagonal_count =
      list
      |> Enum.with_index()
      |> Enum.map(fn {_word, i} -> create_vertical_word_columns(list, i) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.flat_map(&generate_inverse_diagonal_words(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.map(&String.reverse/1)
      |> Enum.count(fn val -> val == @word end)
      |> IO.inspect(label: "DEBUG")

    IO.puts(
      horizontal_count + reverse_horizontal_count + vertical_count + reverse_vertical_count +
        diagonal_count + reverse_diagonal_count + inverse_diagonal_count +
        reverse_inverse_diagonal_count
    )
  end

  def create_horizontal_words(word) do
    word
    |> String.split("")
    |> Enum.with_index()
    |> Enum.map(fn {_k, i} -> get_split_word(word, i) end)
  end

  def get_split_word(word, idx) do
    case idx > String.length(word) - 4 do
      false -> String.slice(word, idx, 4)
      true -> nil
    end
  end

  def create_vertical_word_columns(list_of_words, idx) do
    case idx > length(list_of_words) - 4 do
      false -> Enum.slice(list_of_words, idx, 4)
      true -> nil
    end
  end

  def generate_vertical_words(words) do
    for x <- 0..String.length(Enum.at(words, 0)) do
      [
        String.at(Enum.at(words, 0), x),
        String.at(Enum.at(words, 1), x),
        String.at(Enum.at(words, 2), x),
        String.at(Enum.at(words, 3), x)
      ]
    end
  end

  def generate_diagonal_words(words) do
    for x <- 0..(String.length(Enum.at(words, 0)) - 4) do
      [
        String.at(Enum.at(words, 0), x),
        String.at(Enum.at(words, 1), x + 1),
        String.at(Enum.at(words, 2), x + 2),
        String.at(Enum.at(words, 3), x + 3)
      ]
    end
  end

  def generate_inverse_diagonal_words(words) do
    for x <- 3..(String.length(Enum.at(words, 0))) do
      [
        String.at(Enum.at(words, 0), x),
        String.at(Enum.at(words, 1), x - 1),
        String.at(Enum.at(words, 2), x - 2),
        String.at(Enum.at(words, 3), x - 3)
      ]
    end
  end
end

WordSearch.read_file()
