defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex

  require Logger

  import Common.Sperm

  alias Common.FileUtils
  alias Pappap.{
    Accounts,
    Notifications
  }
  alias PappapWeb.Endpoint

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @tournament_url "/tournament"
  @get_tournament_info_url "/tournament/get"
  @force_to_defeat "/defeat"
  @masters "/masters"
  @duplicate_users "/duplicate_claims"
  @report "/tournament_report"
  @finish "/finish"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/" <> path
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a post request to database server.
  """
  # TODO: ban_mapsとかの場合の処理をここでなんとかする
  # TODO: startとかclaim_scoreここに含めて、defp内で処理を分ける。
  def pass_post_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/" <> path
    |> send_json(params)
    |> IO.inspect(label: :response)
    ~> response

    if response.body["result"] do
      IO.inspect(path, label: :path)
      case path do
        "start"       -> on_start(response.body["data"]["user_id_list"], params["tournament"]["tournament_id"])
        "start_match" -> on_interaction("match_started", response.body["messages"], params["tournament_id"], response.body["rule"])
        "flip_coin"   -> on_interaction("flip_coin",     response.body["messages"], params["tournament_id"], response.body["rule"])
        "ban_maps"    -> on_interaction("banned_map",    response.body["messages"], params["tournament_id"], response.body["rule"])
        "choose_map"  -> on_interaction("chose_map",     response.body["messages"], params["tournament_id"], response.body["rule"])
        "choose_ad"   -> on_interaction("chose_ad",      response.body["messages"], params["tournament_id"], response.body["rule"])
        "claim" <> _  -> on_claim(response.body, params)
        _             -> nil
      end
      |> IO.inspect()
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  defp on_start(user_id_list, tournament_id) when is_list(user_id_list) and is_integer(tournament_id) do
    IO.inspect(user_id_list, label: :asdf)
    Enum.each(user_id_list, fn user_id ->
      topic ="user:#{user_id}"
      msg = "tournament_started"
      payload = %{
        msg: msg,
        tournament_id: tournament_id
      }
      Endpoint.broadcast(topic, msg, payload)
    end)
  end
  defp on_start(_, _), do: :error

  defp on_interaction(msg, messages, tournament_id, rule) when is_list(messages) and is_integer(tournament_id) do
    Enum.each(messages, fn message ->
      topic = "user:#{message["user_id"]}"
      payload = %{
        msg: msg,
        tournament_id: tournament_id,
        state: message["state"],
        rule: rule
      }
      Endpoint.broadcast(topic, msg, payload)
    end)
  end
  defp on_interaction(_, _, _, _), do: :error

  defp on_claim(
    %{"validated" => validated, "completed" => completed,  "is_finished" => is_finished, "messages" => messages, "rule" => rule},
    %{"user_id" => user_id, "opponent_id" => opponent_id, "tournament_id" => tournament_id}
  )
  do
    # NOTE: 重複報告時
    unless validated do
      @db_domain_url <> @api_url <> @get_tournament_info_url
      |> get_parammed_request(%{"tournament_id" => tournament_id})
      |> Map.get(:body)
      |> Map.get("data")
      |> Map.get("master_id")
      ~> master_id

      push_notification_on_game_masters(tournament_id)

      msg = "duplicate_claim"

      Enum.each(messages, fn message ->
        topic = "user:#{message["user_id"]}"
        payload = %{
          tournament_id: tournament_id,
          opponent_id:   opponent_id,
          user_id:       user_id,
          master_id:     master_id,
          msg:           msg,
          state:         message["state"],
          rule:          rule
        }

        Endpoint.broadcast(topic, msg, payload)
      end)
    end

    # NOTE: マッチ完了時
    if completed do
      msg = "match_finished"

      Enum.each(messages, fn message ->
        topic = "user:#{message["user_id"]}"
        payload = %{
          tournament_id: tournament_id,
          opponent_id:   opponent_id,
          user_id:       user_id,
          msg:           msg,
          state:         message["state"],
          rule:          rule
        }
        Endpoint.broadcast(topic, msg, payload)
      end)
    end

    # NOTE: 大会終了時
    if is_finished do
      msg = "tournament_finished"

      Enum.each(messages, fn message ->
        topic = "user:#{message["user_id"]}"
        payload = %{
          tournament_id: tournament_id,
          opponent_id:   opponent_id,
          user_id:       user_id,
          msg:           msg,
          state:         message["state"],
          rule:          rule
        }
        Endpoint.broadcast(topic, msg, payload)
      end)
    end
  end

  @doc """
  Pass a request of home to database server
  """
  def pass_home_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/home/" <> path
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Creates a tournament.
  """
  def create(conn, params) do
    unless params["image"] == "" do
      uuid = SecureRandom.uuid()
      FileUtils.copy(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/"<>uuid<>".jpg"
    else
      "./static/image/default_BG.png"
    end
    ~> file_path

    @db_domain_url <> @api_url <> @tournament_url
    |> send_tournament_multipart(params, file_path)
    ~> response

    unless params["image"] == "", do: File.rm(file_path)

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  defp push_notification_on_game_masters(tournament_id) do
    @db_domain_url <> @api_url <> @tournament_url <> @masters
    |> get_parammed_request(%{"tournament_id" => tournament_id})
    ~> response

    if is_list(response.body["data"]) do
      response.body["data"]
      |> IO.inspect()
      |> Enum.each(fn master ->
        master["id"]
        |> Accounts.get_devices_by_user_id()
        |> IO.inspect()
        |> Enum.each(fn device ->
          users_str = get_duplicate_users(tournament_id)
          Notifications.push("勝敗報告にズレが生じています！ : " <> users_str, device.device_id, 7)
        end)
      end)
    end
  end

  defp get_duplicate_users(tournament_id) do
    @db_domain_url <> @api_url <> @tournament_url <> @duplicate_users
    |> get_parammed_request(%{"tournament_id" => tournament_id})
    |> Map.get(:body)
    |> Map.get("data")
    ~> data

    unless is_nil(data) do
      Enum.reduce(data, "", fn user, acc ->
        acc <> user["name"] <> " "
      end)
    else
      ""
    end
  end

  @doc """
  Force to defeat a user.
  """
  def force_to_defeat(conn, params) do
    @db_domain_url <> @api_url <> @tournament_url <> @force_to_defeat
    |> send_json(params)
    ~> response

    if response.body["result"] do
      topic = "tournament:" <> to_string(params["tournament_id"])
      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Finishes a tournament.
  """
  def finish(conn, params) do
    @db_domain_url <> @api_url <> @tournament_url <> @finish
    |> send_json(params)
    ~> response

    id = params["tournament_id"]

    if response.body["result"] do
      topic = "tournament:" <> to_string(id)
      PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished", id: id})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Report
  """
  def report(conn, params) do
    @db_domain_url <> @api_url <> @report
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  # DEBUG:
  def debug_tournament_ws(conn, %{"tournament_id" => id, "state" => state}) do
    IO.inspect(conn, label: :state_conn)
    id = unless is_binary(id), do: to_string(id)

    #PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, state, %{msg: state, id: id})

    json(conn, %{msg: "done"})
  end

  def debug_tournament_ws(conn, %{"tournament_id" => id}) do
    IO.inspect(conn, label: :conn)
    id = unless is_binary(id), do: to_string(id)

    PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, "tournament_started", %{msg: "debug notification", id: id})

    json(conn, %{msg: "done"})
  end

  def redirect_by_url(conn, params) do
    conn
    |> Map.get(:req_headers)
    |> Enum.filter(fn header ->
      header
      |> elem(0)
      |> Kernel.==("user-agent")
    end)
    |> hd()
    |> elem(1)
    |> IO.inspect()
    |> UAInspector.parse()
    |> IO.inspect()
    |> Map.get(:os)
    |> Map.get(:name)
    |> IO.inspect()
    ~> os_name

    path = params["url"]

    params = Map.put(params, "os_name", os_name)

    @db_domain_url <> "/api/tournament/url/#{path}"
    |> get_parammed_request(params)
    ~> response
    |> Map.get(:body)
    |> case do
      %{"result" => false} ->
        conn
        |> put_status(response.status_code)
        |> json(response.body)
      map ->
        IO.inspect(map)
        url = map["url"]
        redirect(conn, external: url)
    end
  end
end
