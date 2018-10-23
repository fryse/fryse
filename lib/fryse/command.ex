defmodule Fryse.Command do
  @moduledoc false

  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :shortdoc, persist: true

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
end
