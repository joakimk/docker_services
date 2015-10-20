defmodule DockerServices.CLI do
  def main([ "backup", service, archive_path ]) do
    command(:stop)
    DockerServices.Backup.backup(service, archive_path)
    command(:start)
  end

  def main([ "restore", service, archive_path ]) do
    command(:stop)
    DockerServices.Backup.restore(service, archive_path)
    command(:start)
  end

  def main([]),   do: command("")
  def main(args), do: command(args |> hd |> String.to_atom)

  def command(:bootstrap), do: DockerServices.Bootstrap.run
  def command(:help),      do: DockerServices.Help.show
  def command(:start),     do: DockerServices.Runner.start
  def command(:stop),      do: DockerServices.Runner.stop

  def command(other) do
    IO.puts "Unknown command: #{other}\n"
    command(:help)
  end
end
