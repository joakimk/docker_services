defmodule JSON do
  def parse(text), do: Poison.Parser.parse!(text)
end
