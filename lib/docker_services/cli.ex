defmodule DockerServices.CLI do
  def main([ single_argument ]), do: command(single_argument |> String.to_atom)
  def main([ "backup", service, archive_path ]), do: DockerServices.Backup.backup(service, archive_path)
  def main([ "restore", service, archive_path ]), do: DockerServices.Backup.restore(service, archive_path)

  def command(:bootstrap), do: DockerServices.Bootstrap.run
  def command(:help),      do: DockerServices.Help.show
  def command(:start),     do: DockerServices.Runner.start
  def command(:stop),      do: DockerServices.Runner.stop

  def main([]), do: command("")

  def command(other) do
    IO.puts "Unknown command: #{other}\n"
    command(:help)
  end
end
