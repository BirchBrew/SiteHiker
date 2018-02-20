defmodule Web.Router do
  use Plug.Router
  import Data.AlexaScraper

  @page File.read!("static/page.html")

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, @page)
  end

  get "/:site" do
    conn
    |> put_resp_content_type("text/json")
    |> send_resp(200, Poison.encode!(%{related_sites: get_sites_similar_to(site)}))
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
