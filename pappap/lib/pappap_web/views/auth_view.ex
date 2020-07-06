defmodule PappapWeb.AuthView do
  use PappapWeb, :view

  def render("show.json", %{} = body) do
    body
  end

  def render("error.json", msg, error_no) do
    %{
      "result" => false,
      "reason" => msg,
      "error_no" => error_no
    }
  end
end