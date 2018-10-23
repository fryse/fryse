defmodule Fryse.CLI.Serve do
  use Fryse.Command

  @shortdoc "Serves static files"

  @moduledoc false

  def run(args) do
    {switches, _, _} = OptionParser.parse(args, switches: [port: :integer])

    port = Keyword.get(switches, :port, 7777)

    Application.start(:cowboy)
    Application.start(:plug)
    IO.puts("Starting server. Browse to http://localhost:#{port}/")
    IO.puts("Press <CTRL+C> to quit.")
    {:ok, _pid} = Plug.Adapters.Cowboy.http(Fryse.Plug.Server, [], port: port)

    :timer.sleep(:infinity)
  end
end
