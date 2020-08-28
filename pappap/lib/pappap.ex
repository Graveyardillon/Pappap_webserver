defmodule Pappap do
  @moduledoc """
  Pappap keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  def connect() do
    with {:ok, socket} <- :gen_tcp.connect('localhost', 4041, [:binary, active: false]) do
      Logger.info("Connected to DB Server in TCP")
      loop_receiver(socket)
    else
      {:error, :econnrefused} -> Logger.warn("Could not connect to DB Server. (Refused)")
      _ -> Logger.warn("Could not connect to DB Server due to unexpected reasons.")
    end
  end

  defp loop_receiver(socket) do
    {:ok, _data} = :gen_tcp.recv(socket, 0)
    loop_receiver(socket)
  end

  defp close_socket(socket) do
    :gen_tcp.send(socket, "close")
  end
end
