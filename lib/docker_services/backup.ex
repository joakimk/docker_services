defmodule DockerServices.Backup do
  def backup(service, archive_path) do
    path = System.cwd
    File.cd(DockerServices.Paths.project_data_root)

    result = with_progressbar "backing up #{service} to #{archive_path}", "#{service} backed up to #{archive_path}", fn ->
      DockerServices.Shell.run("sudo tar cfzp #{archive_path} #{service}")
    end

    File.cd(path)
    { :ok, _, 0 } = result
  end

  defp with_progressbar(text, done, callback), do: DockerServices.WithProgressBar.run(text, done, callback)
end
