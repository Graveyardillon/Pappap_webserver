defmodule PappapWeb.ReportController do
  use PappapWeb, :controller

  def register_match(conn, %{"match" => match_params}) do
    id =
      :ets.match(:match_result, {"last_match", :"$1"})
      |>hd()
      |>hd()
      |>Kernel.+(1)
      |>insert_with_number(match_params)
    :ets.insert(:match_result, {"last_match", id})
    json(conn, %{match_id: id})
  end

  def report(conn, %{"report" => result_params}) do
    [{id, players, result}] = :ets.lookup(:match_result, result_params["id"])
    case result do
      nil ->
        :ets.insert(:match_result, {id, players, result_params["win"]})
        json(conn, %{msg: "first_input"})
      _ ->
        if result == result_params["win"] do
          :ets.delete(:match_result, id)
          :ets.insert(:match_result, {"last_match",id - 1})
          json(conn, %{msg: "completed"})
        else
          json(conn, %{msg: "conflict"})
        end
    end
  end

  defp insert_with_number(num,params) do
    unless :ets.insert_new(:match_result, {num,[params["player1"], params["player2"]], nil}) do
      insert_with_number(num + 1, params)
    else
      num
    end
  end
end