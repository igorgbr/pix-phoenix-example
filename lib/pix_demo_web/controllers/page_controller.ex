defmodule PixDemoWeb.PageController do
  use PixDemoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
