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
    {:ok, socket} = :gen_tcp.connect('localhost', 4041, [:binary, active: false])
    Logger.info("Connected to DB Server in TCP")

    loop_receiver(socket)
  end

  defp loop_receiver(socket) do
    {:ok, _data} = :gen_tcp.recv(socket, 0)
    loop_receiver(socket)
  end

  def sync_users() do
    {:ok, socket} = :gen_tcp.connect('localhost', 4041, [:binary, active: false])
    Logger.info("User Sync Connected")

    :ok = :gen_tcp.send(socket, "user_sync")
    loop_id_receiver(socket)

    close_socket(socket)
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
