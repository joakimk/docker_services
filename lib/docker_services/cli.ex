defmodule DockerServices.CLI do
  def main([ "init" ]) do
    DockerServices.Init.run
  end

  def main(args) do
    IO.puts "Unknown command or arguments: #{inspect(args)}"
    System.halt(1)
  end
end
