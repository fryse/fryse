defmodule Fryse.Command do
  @moduledoc false

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :shortdoc, persist: true
      import unquote(__MODULE__), only: [stop: 0, stop: 1]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    moduledoc = Module.get_attribute(env.module, :moduledoc)

    quote do
      def moduledoc() do
        {_, moduledoc} = unquote(moduledoc)
        moduledoc
      end
    end
  end

  def stop(code \\ 0) do
    #TODO: Wait until http://erlang.org/pipermail/erlang-bugs/2014-June/004450.html is resolved and change back to `System.stop()`
    System.halt(code)
  end
end
