defmodule PappapWeb.PreflightController do
  use PappapWeb, :controller

  def preflight(conn, _) do
    IO.inspect(conn, label: :preflight)
    json(conn, %{result: true})
  end
end
