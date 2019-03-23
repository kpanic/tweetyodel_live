defmodule TweetyodelLiveWeb.Tweetyodel do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <form phx-submit="search">
      <input type="text" name="keyword" value="<%= @keyword %>" list="matches" placeholder="Search..."
      <div class="divTable">
        <%= for tweet_text <- @tweet_stream do %>
          <div class="divTableBody">
            <div class="divTableRow">
              🐦 <%= tweet_text %>
            </div>
          </div>
        <% end %>
        </div>
    </form>
    """
  end

  def mount(_session, socket) do
    send(self(), {:put, "linux"})
    if connected?(socket), do: :timer.send_interval(100, self(), :tweet_tick)

    {:ok, assign(socket, keyword: nil, tweet_stream: ["..."])}
  end

  def handle_event("search", %{"keyword" => search_keywords}, socket) do
    IO.inspect("SEARCH")
    IO.inspect(search_keywords)
    Tweetyodel.Worker.stop_stream("tweetyodel_live") |> IO.inspect(label: "STOP")

    Tweetyodel.Worker.start_stream("tweetyodel_live", search_keywords)
    |> IO.inspect(label: "START")

    {:noreply, refresh_stream(socket)}
  end

  def handle_info({:put, search_keywords}, socket) do
    Tweetyodel.Worker.stop_stream("tweetyodel_live")
    Tweetyodel.Worker.start_stream("tweetyodel_live", search_keywords)
    {:noreply, refresh_stream(socket)}
  end

  def handle_info(:tweet_tick, socket) do
    {:noreply, refresh_stream(socket)}
  end

  defp refresh_stream(socket) do
    assign(socket, tweet_stream: tweet_stream())
  end

  defp tweet_stream() do
    Enum.map(Tweetyodel.Worker.entries("tweetyodel_live"), fn tweet ->
      tweet.text
    end)
  end
end
