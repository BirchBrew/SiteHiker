defmodule Router.Dynamic do
  use Plug.Router
  import Data.AlexaScraper

  plug(:match)
  plug(:dispatch)

  get "/:site" do
    related_sites_json = Poison.encode!(%{relatedSites: get_sites_similar_to(site)})
    conn
    |> put_resp_content_type("text/json")
    |> send_resp(200, related_sites_json)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
