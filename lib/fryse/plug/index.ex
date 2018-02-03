defmodule Fryse.Plug.Index do
  @moduledoc """
  Plug to serve index.html files
  """

  @behaviour Plug

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: path} = conn, _opts) do
    path = Path.join("./_site", Path.join(path, "index.html"))

    if File.exists?(path) do
      conn
      |> Plug.Conn.send_file(200, path)
      |> Plug.Conn.halt()
    else
      conn
    end
  end
end
