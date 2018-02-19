defmodule AWIS do
  @data_dir "data"

  @awis_url "https://awis.amazonaws.com/api"
  @region "us-east-1"
  @response_groups ~w(
    Categories
    Rank
    RankByCountry
    UsageStats
    AdultContent
    Speed
    Language
    OwnedDomains
    LinksInCount
    SiteData
  ) |> Enum.join(",")

  ##############
  # PUBLIC API #
  ##############
  def url_info(url) do
    params = %{
      Action: "UrlInfo",
      Url: url,
      ResponseGroup: @response_groups
    }
    download_data(url, params)
  end

  #####################
  # PRIVATE FUNCTIONS #
  #####################
  defp download_data(url, params) do
    path = Path.join(@data_dir, "#{url}.xml")
    file = File.open!(path, [:write])
    data = fetch_data(params)
    IO.binwrite(file, data)
    File.close(file)
  end

  defp fetch_data(params) do
    full_url = build_full_url(params)
    HTTPoison.get!(full_url, signed_request_headers(full_url))
  end

  defp build_full_url(params) do
    "#{@awis_url}?#{URI.encode_query(params)}"
  end

  defp signed_request_headers(url) do
    {:ok, %{} = sig_data, _} =
      Sigaws.sign_req(
        url,
        region: @region,
        service: "awis",
        access_key: System.get_env("AWS_ACCESS_KEY_ID"),
        secret: System.get_env("AWS_SECRET_ACCESS_KEY")
      )

    sig_data
  end
end
