defmodule LaterWeb.PageController do
  use LaterWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
