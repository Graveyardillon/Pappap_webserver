defmodule PappapWeb.TournamentChannel do
  use PappapWeb, :channel

  @impl true
  def join("tournament:" <> _tournament_id, %{"user_id" => user_id}, socket) do
    if authorized?(user_id) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (tournament:lobby).
  @impl true
  def handle_in("new_notice", payload, socket) do
    payload
    |> Map.has_key?("info")
    |> if do
      IO.inspect(payload["info"])
    end
    broadcast socket, "new_notice", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(user_id) do
    true
  end
end
