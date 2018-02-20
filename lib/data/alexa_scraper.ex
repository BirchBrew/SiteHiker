defmodule Data.AlexaScraper do
  @site_info_url "https://www.alexa.com/siteinfo"
  @timeout_ms 10_000

  def get_sites_similar_to(site) do
    HTTPoison.get!("#{@site_info_url}/#{site}", %{}, recv_timeout: @timeout_ms)
    |> Map.get(:body)
    |> Floki.find("#audience_overlap_table a")
    |> Enum.map(&elem(&1, 2))
    |> Enum.map(&hd/1)
  end
end
