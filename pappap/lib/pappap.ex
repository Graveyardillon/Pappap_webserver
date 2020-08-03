defmodule Pappap do
  @moduledoc """
  Pappap keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  def connect() do
    {:ok, socket} = :gen_tcp.connect('localhost', 4041, [:binary, active: false])
    send_messages(socket, 0)
  end

  defp send_messages(socket, num) do
    :timer.sleep(1000)
    :ok = :gen_tcp.send(socket, Integer.to_string(num))
    #Logger.info(@msg)
    {:ok, _data} = :gen_tcp.recv(socket, 0)
    send_messages(socket, num+1)
  end
end
