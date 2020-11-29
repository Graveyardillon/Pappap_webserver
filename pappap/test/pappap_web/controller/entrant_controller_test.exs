defmodule PappapWeb.EntrantControllerTest do
  use PappapWeb.ConnCase

  describe "show entrant's rank" do
    test "show the rank when receive valid user and tournament id", %{conn: conn} do
      conn = get(conn, Routes.entrant_path(conn, :show_rank, 1, 1))
      assert is_integer(json_response(conn, 200)["data"]["rank"])
    end

    test "show the rank when receive invalid user id and valid tournament id", %{conn: conn} do
      conn = get(conn, Routes.entrant_path(conn, :show_rank, -1, 1))
      assert json_response(conn, 200)["error"] == "entrant is not found"
    end

    test "show the rank when receive valid user id and invalid tournament id", %{conn: conn} do
      conn = get(conn, Routes.entrant_path(conn, :show_rank, 1, -1))
      assert json_response(conn, 200)["error"] == "entrant is not found"
    end

    test "show the rank when receive invalid user id and invalid tournament id", %{conn: conn} do
      conn = get(conn, Routes.entrant_path(conn, :show_rank, -1, -1))
      assert json_response(conn, 200)["error"] == "entrant is not found"
    end
  end
end