defmodule AWIS do
  @data_dir "data"
  @request_counter_file "request_counter.txt"
  @request_limit 1000

  @region "us-west-1"
  @awis_url "https://awis.#{@region}.amazonaws.com/api"
  @url_info_response_groups ~w(
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
  def get_data_for_urls(urls) when is_list(urls) do
    Enum.each(urls, &get_data_for_single_url/1)
  end

  #####################
  # PRIVATE FUNCTIONS #
  #####################
  defp get_data_for_single_url(url) do
    url_info(url)
    # TODO make the rest of the API calls here if needed
    :ok
  end

  defp url_info(url) do
    params = %{
      Action: "UrlInfo",
      Url: url,
      ResponseGroup: @url_info_response_groups
    }

    download_data(:url_info, url, params)
  end

  defp download_data(type_of_data, url, params) do
    data_output_file = open_data_output_file(type_of_data, url)
    data = fetch_data(params)
    IO.binwrite(data_output_file, data)
    File.close(data_output_file)
  end

  defp open_data_output_file(type_of_data, url) do
    url_specific_data_path = Path.join(@data_dir, url)

    unless File.exists?(url_specific_data_path) do
      File.mkdir!(url_specific_data_path)
    end

    download_filepath = Path.join(url_specific_data_path, "#{type_of_data}.xml")
    File.open!(download_filepath, [:write])
  end

  defp fetch_data(params) do
    full_url = build_full_url(params)
    headers = signed_request_headers(full_url)
    increment_counter()
    %HTTPoison.Response{body: body, status_code: 200} = HTTPoison.get!(full_url, headers)
    body
  end

  defp build_full_url(params) do
    "#{@awis_url}?#{URI.encode_query(params)}"
  end

  defp signed_request_headers(url) do
    [access_key, secret] =
      Path.join("secrets", "keys.csv")
      |> File.read!()
      |> String.trim()
      |> String.split(",")

    {:ok, %{} = sig_data, _} =
      Sigaws.sign_req(
        url,
        region: @region,
        service: "awis",
        access_key: access_key,
        secret: secret
      )

    sig_data
  end

  # TODO this is bad, pls replace with something cleaner
  defp increment_counter do
    count =
      File.read!(@request_counter_file)
      |> String.trim()
      |> String.to_integer()

    new_count = count + 1

    if new_count > @request_limit do
      raise "YOU'VE RUN OUT OF FREE REQUESTS! THINK OF YOUR WALLET!"
    end

    File.write!(@request_counter_file, to_string(count + 1))
  end
end
