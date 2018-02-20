defmodule Router do
  use Plug.Builder

  plug(Router.Static)
  plug(Router.Dynamic)
end
