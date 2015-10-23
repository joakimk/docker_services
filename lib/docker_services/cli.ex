defmodule DockerServices.CLI do
  def main([ first_argument | rest ]), do: command(first_argument |> String.to_atom, rest)

  def command(:backup,  [ service, archive_path ]), do: DockerServices.Backup.backup(service, archive_path)
  def command(:restore, [ service, archive_path ]), do: DockerServices.Backup.restore(service, archive_path)
  def command(name, _),    do: command(name)

  def command(:bootstrap), do: DockerServices.Bootstrap.run
  def command(:help),      do: DockerServices.Help.show
  def command(:start),     do: DockerServices.Runner.start
  def command(:stop),      do: DockerServices.Runner.stop

  def command(other) do
    IO.puts "Unknown command: #{other}\n"
    command(:help)
  end
end
