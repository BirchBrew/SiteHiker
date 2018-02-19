defmodule TopSitesParser do
  @num_lines_in_pattern 12

  def parse_file(file_path) do
    input_file = File.open!(file_path, [:read])

    lines = IO.binread(input_file, :all)
    |> String.split(~r{(\r\n|\r|\n)}) # saplit on newlines
    |> tl() # drop the first element
    |> Enum.take_every(@num_lines_in_pattern)
    |> Enum.map(&String.downcase/1)
    File.close(input_file)

    output_file = File.open!(file_path, [:write])
    Enum.each(lines, &IO.puts(output_file, &1))
    File.close(output_file)
  end
end

file_to_process = System.argv() |> hd()
IO.puts("Processing #{file_to_process}...")
TopSitesParser.parse_file(file_to_process)
IO.puts("Done!")
