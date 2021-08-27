defmodule PappapWeb.PendingTournamentChannel do
  use PappapWeb, :channel
  require Logger

  @impl true
  def join("pending_tournament:" <> tournament_id,  %{"user_id" => user_id}, socket) do
    Logger.info("user #{user_id} has joined pending_tournament #{tournament_id}")
    {:ok, socket}
  end
end
