defmodule TwitterSimulationWeb.PageController do
  use TwitterSimulationWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
