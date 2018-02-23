require Logger

defmodule Data.AlexaSimilarSites do
  use GenServer

  @name __MODULE__
  @state_file "data/#{@name}.state"
  @site_info_url "https://www.alexa.com/find-similar-sites/data?site="
  @timeout_ms 10_000

  ##############
  # PUBLIC API #
  ##############
  def start_link([]) do
    GenServer.start_link(@name, :ok, name: @name)
  end

  def get_similar(url) do
    GenServer.call(@name, {:get_similar, url})
  end

  # TODO remove this function after thouroughly testing this module
  def inspect_state do
    GenServer.call(@name, :inspect)
  end

  ####################
  # SERVER CALLBACKS #
  ####################
  def init(:ok) do
    state = load_state()

    {:ok, state}
  end

  def handle_call({:get_similar, url}, _from, state = {similar, ranks}) do
    host = Util.URL.parse(url)

    case Map.get(similar, host) do
      nil ->
        Logger.info("Cache miss for '#{host}'. Fetching from Alexa...")

        {host_rank_mapping, similar_sites_data} = fetch_data_from_alexa(host)
        similar_rank_mappings = get_rank_mappings(similar_sites_data)
        ranks = update_rankings(ranks, host_rank_mapping, similar_rank_mappings)

        similar_site_overlap_tuples = get_site_overlap_tuples(similar_sites_data)
        similar = update_similar(similar, host, similar_site_overlap_tuples)

        state = {similar, ranks}
        save_state(state)
        {:reply, similar_site_overlap_tuples, state}

      similar_site_overlap_tuples ->
        Logger.info("Serving '#{host}' data from cache")
        {:reply, similar_site_overlap_tuples, state}
    end
  end

  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end

  ###################
  # PRIVATE HELPERS #
  ###################
  defp load_state() do
    case File.read(@state_file) do
      {:ok, saved_state} -> :erlang.binary_to_term(saved_state)
      {:error, :enoent} -> {%{}, %{}}
    end
  end

  defp save_state(state) do
    binary_state = :erlang.term_to_binary(state)
    File.write!(@state_file, binary_state)
  end

  defp get_rank_mappings(similar_sites) do
    Enum.reduce(similar_sites, %{}, fn site_entry, rankings ->
      Map.put(rankings, site_entry["site2"], site_entry["alexa_rank"])
    end)
  end

  defp update_rankings(ranks, host_rank_mapping, similar_rank_mappings) do
    Map.merge(ranks, host_rank_mapping) |> Map.merge(similar_rank_mappings)
  end

  defp get_site_overlap_tuples(similar_sites) do
    Enum.map(similar_sites, fn site_entry ->
      {site_entry["site2"], site_entry["overlap_score"]}
    end)
  end

  defp update_similar(similar, host, similar_sites_data) do
    Map.put(similar, host, similar_sites_data)
  end

  defp fetch_data_from_alexa(host) do
    results =
      HTTPoison.get!(@site_info_url <> host, %{}, recv_timeout: @timeout_ms)
      |> Map.get(:body)
      |> Jason.decode!()
      |> Map.get("results")
      |> Enum.filter(&Map.has_key?(&1, "site2"))

    [site_data = %{"site2" => ^host} | similar_sites] = results
    rank_mapping = %{host => site_data["alexa_rank"]}
    {rank_mapping, similar_sites}
  end
end
