defmodule Fryse.Plug.Server do
  @moduledoc """
  Serving generated site from `./_site`
  """
  use Plug.Builder

  plug Plug.Static, at: "/", from: "./_site/"
  plug Fryse.Plug.Index
  plug :not_found

  @doc """
  Sends all unknown requests a 404.
  """
  def not_found(conn, _) do
    Plug.Conn.send_resp(
      conn,
      404,
      "Page not found"
    )
  end
end
