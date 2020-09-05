defmodule PappapWeb.ProfileView do
  use PappapWeb, :view

  def render("send.json", %{} = body) do
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