defmodule DockerServices.Backup do
  def backup(service, archive_path) do
    within_project_data_root fn ->
      with_progressbar "backing up #{service} to #{archive_path}", "#{service} backed up to #{archive_path}", fn ->
        DockerServices.Shell.run("sudo tar cfzp #{archive_path} #{service}")
      end
    end
  end

  def restore(service, archive_path) do
    within_project_data_root fn ->
      with_progressbar "restore #{service} from #{archive_path}", "#{service} restored", fn ->
        DockerServices.Shell.run("sudo rm -rf #{service}") # okay if this fails
        DockerServices.Shell.run("sudo tar xfz #{archive_path}")
      end
    end
  end

  defp within_project_data_root(callback) do
    path = System.cwd
    File.cd(DockerServices.Paths.project_data_root)

    result = callback.()

    File.cd(path)
    { :ok, _, 0 } = result
  end

  defp with_progressbar(text, done, callback), do: DockerServices.WithProgressBar.run(text, done, callback)
end
