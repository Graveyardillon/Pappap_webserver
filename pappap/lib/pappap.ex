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
    Logger.info("Connected to DB Server in TCP")

    :gen_tcp.recv(socket, 0)
    #:gen_tcp.send(socket, "close")
  end

  def sync_users() do
    {:ok, socket} = :gen_tcp.connect('localhost', 4041, [:binary, active: false])
    Logger.info("User Sync Connected")

    :ok = :gen_tcp.send(socket, "user_sync")
    {:ok, data} = :gen_tcp.recv(socket, 0)
    #:gen_tcp.send(socket, "close")
  end
end
