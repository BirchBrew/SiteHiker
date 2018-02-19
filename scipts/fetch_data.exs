urls = File.read!("data/top_sites_us.txt") |> String.trim() |> String.split(~r{(\r\n|\r|\n)})

IO.puts("Fetching data about #{inspect urls}...")
AWIS.get_data_for_urls(urls)
IO.puts("Done!")
