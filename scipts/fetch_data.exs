url = System.argv() |> hd()

IO.puts("Fetching data about #{url}...")
AWIS.get_data_for_urls([url])
IO.puts("Done!")
