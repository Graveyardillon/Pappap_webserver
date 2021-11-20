defmodule PappapWeb.PreflightController do
  use PappapWeb, :controller

  def preflight(conn, _) do
    json(conn, %{result: true})
  end
end
