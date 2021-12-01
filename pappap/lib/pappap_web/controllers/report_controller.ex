defmodule PappapWeb.ReportController do
  use PappapWeb, :controller
  use Common.Tools

  # TODO: 何の処理か忘れたから確認して消す
  def report(conn, %{"report" => result_params}) do
    [{id, players, result}] = :ets.lookup(:match_result, result_params["id"])
    case result do
      nil ->
        :ets.insert(:match_result, {id, players, result_params["lose"]})
        json(conn, %{msg: "first_input"})
      _ ->
        if result == result_params["lose"] do
          :ets.delete(:match_result, id)
          if :ets.match(:match_result, {"last_match", :"$1"})|>hd()|>hd() > id - 1 do
            :ets.insert(:match_result, {"last_match",id - 1})
          end
          json(conn, %{msg: "completed",loser: result})
        else
          :ets.insert(:match_result, {id, players, nil})
          json(conn, %{msg: "conflict"})
        end
    end
  end
end
