require Logger

defmodule Router.Dynamic do
  use Plug.Router
  import Data.AlexaSimilarSites

  plug(:match)
  plug(:fetch_query_params)
  plug(:dispatch)

  get "/lookup" do
    case conn.query_params do
      %{"site" => site} ->
        handle_lookup(conn, site)

      _ ->
        handle_error(conn)
    end
  end

  match _ do
    send_resp(conn, 404, "")
  end

  def handle_lookup(conn, site) do
    similar_sites_list = site |> URI.decode() |> get_similar() |> Enum.map(&elem(&1, 0))
    related_sites_json = Jason.encode!(%{relatedSites: similar_sites_list})

    conn
    |> put_resp_content_type("text/json")
    |> send_resp(200, related_sites_json)
  end

  def handle_error(conn) do
    send_resp(conn, 400, "Bad Request!")
  end

  def fetch_query_params(conn) do
    Plug.Conn.fetch_query_params(conn)
  end
end
