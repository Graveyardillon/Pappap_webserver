defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex

  require Logger

  import Common.Sperm

  alias Common.{
    FileUtils,
    Tools
  }
  alias PappapWeb.Endpoint

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @tournament_url "/tournament"
  @force_to_defeat "/defeat"
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
  def pass_post_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/" <> path
    |> send_json(params)
    ~> response

    if response.body["result"] do
      case path do
        "start"       -> on_interaction("tournament_started", response.body["data"]["messages"], Tools.to_integer_as_needed(params["tournament"]["tournament_id"]), response.body["data"]["rule"])
        "start_match" -> on_interaction("match_started",      response.body["messages"],         Tools.to_integer_as_needed(params["tournament_id"]),               response.body["rule"])
        "flip_coin"   -> on_interaction("flip_coin",          response.body["messages"],         Tools.to_integer_as_needed(params["tournament_id"]),               response.body["rule"])
        "ban_maps"    -> on_interaction("banned_map",         response.body["messages"],         Tools.to_integer_as_needed(params["tournament_id"]),               response.body["rule"])
        "choose_map"  -> on_interaction("chose_map",          response.body["messages"],         Tools.to_integer_as_needed(params["tournament_id"]),               response.body["rule"])
        "choose_ad"   -> on_interaction("chose_ad",           response.body["messages"],         Tools.to_integer_as_needed(params["tournament_id"]),               response.body["rule"])
        "claim" <> _  -> on_claim(response.body, params)
        _             -> nil
      end
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

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
    %{
      "validated" => validated,
      "completed" => completed,
      "is_finished" => is_finished,
      "messages" => messages,
      "opponent_user_id" => opponent_user_id,
      "rule" => rule,
      "user_id" => user_id
    },
    %{"tournament_id" => tournament_id}
  )
  do
    tournament_id = Tools.to_integer_as_needed(tournament_id)
    # NOTE: 重複報告時
    unless validated do
      msg = "duplicate_claim"

      Enum.each(messages, fn message ->
        topic = "user:#{message["user_id"]}"
        payload = %{
          tournament_id: tournament_id,
          opponent_id:   opponent_user_id,
          user_id:       user_id,
          master_id:     nil,
          msg:           msg,
          state:         message["state"],
          rule:          rule
        }

        Endpoint.broadcast(topic, msg, payload)
      end)
    end
    # NOTE: ここからのopponent_user_idはすべて対戦相手のチームの代表
    # NOTE: user_idは自身のチームの代表
    # NOTE: 個人戦の場合はそのまま個人

    # NOTE: マッチ完了時
    if completed do
      msg = "match_finished"

      Enum.each(messages, fn message ->
        topic = "user:#{message["user_id"]}"
        payload = %{
          tournament_id: tournament_id,
          opponent_id:   opponent_user_id,
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
          opponent_id:   opponent_user_id,
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
    is_image_nil? = params["image"] == "" or is_nil(params["image"])

    if !is_image_nil? do
      uuid = SecureRandom.uuid()
      FileUtils.copy(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/#{uuid}.jpg"
    else
      "./static/image/default_BG.png"
    end
    ~> file_path

    @db_domain_url <> @api_url <> @tournament_url
    |> send_tournament_multipart(params, file_path)
    ~> response

    unless is_image_nil?, do: File.rm(file_path)

    conn
    |> put_status(response.status_code)
    |> json(response.body)
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
    id = unless is_binary(id), do: to_string(id)

    #PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, state, %{msg: state, id: id})

    json(conn, %{msg: "done"})
  end

  def debug_tournament_ws(conn, %{"tournament_id" => id}) do
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
    |> UAInspector.parse()
    |> Map.get(:os)
    |> Map.get(:name)
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
        url = map["url"]
        redirect(conn, external: url)
    end
  end
end
