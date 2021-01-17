defmodule PappapWeb.AuthView do
  use PappapWeb, :view

  def render("show.json", %{} = body) do
    body
  end

  def render("error.json", msg, _error_no) do
    %{
      "result" => false,
      "reason" => msg
    }
  end
end
