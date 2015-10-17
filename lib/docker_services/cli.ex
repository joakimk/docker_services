defmodule DockerServices.CLI do
  def main([ "init" ]) do
    DockerServices.Init.run
  end

  def main(args) do
    IO.inspect "Unknown args: #{args}"
  end
end
