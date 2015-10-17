defmodule DockerServices.CLI do
  def main([ "bootstrap" ]) do
    DockerServices.Bootstrap.run
    IO.puts "Bootstrap complete, now go read: https://github.com/joakimk/docker_services#hooking-into-cd"
  end

  def main([ "help" ]) do
    DockerServices.Help.show
  end

  def main(args) do
    IO.puts "Unknown command or arguments: #{inspect(args)}\n"

    main([ "help" ])
  end
end
