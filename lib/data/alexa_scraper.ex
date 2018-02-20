defmodule Data.AlexaScraper do
  @site_info_url "https://www.alexa.com/siteinfo"

  def get_sites_similar_to(site) do
    HTTPoison.get!("#{@site_info_url}/#{site}")
    |> Map.get(:body)
    |> Floki.find("#audience_overlap_table a")
    |> Enum.map(&elem(&1, 2))
    |> Enum.map(&hd/1)
  end
end
