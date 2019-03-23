defmodule TweetyodelLiveWeb.PageController do
  use TweetyodelLiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
