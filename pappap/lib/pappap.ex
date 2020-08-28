defmodule Pappap do
  @moduledoc """
  Pappap keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  alias Pappap.Accounts

  def connect() do
    with {:ok, socket} <- :gen_tcp.connect('localhost', 4041, [:binary, active: false]) do
      Logger.info("Connected to DB Server in TCP")
      loop_receiver(socket)
    else
      {:error, :econnrefused} -> Logger.info("Could not connect to DB Server. (Refused)")
      _ -> Logger.info("Could not connect to DB Server due to unexpected reasons.")
    end
  end

  defp loop_receiver(socket) do
    {:ok, _data} = :gen_tcp.recv(socket, 0)
    loop_receiver(socket)
  end

  def sync_users() do
    with {:ok, socket} <- :gen_tcp.connect('localhost', 4041, [:binary, active: false]) do
      Logger.info("User Sync Connected")
      send_user_sync_request(socket)
    else
      _ -> Logger.info("Could not sync user due to unexpected reasons.")
    end
  end

  defp send_user_sync_request(socket) do
    with :ok <- :gen_tcp.send(socket, "user_sync") do
      loop_id_receiver(socket)
      close_socket(socket)
    else
      _ -> Logger.info("Could not sync user due to unexpected reasons.")
    end
  end

  defp loop_id_receiver(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    #_pid = spawn(Accounts, :create_new_user, [%{user_id: data}])
    # 非同期にすると正常にデータが受け取れない。
    Accounts.create_new_user(%{user_id: data})
    loop_id_receiver(socket)
  end

  defp close_socket(socket) do
    :gen_tcp.send(socket, "close")
  end
end
