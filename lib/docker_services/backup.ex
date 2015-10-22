defmodule DockerServices.Backup do
  def backup(service, archive_path) do
    DockerServices.Runner.stop

    with_progressbar "backing up #{service} to #{archive_path}", "#{service} backed up to #{archive_path}", fn ->
      DockerServices.Shell.run!("cd #{data_root_path} && tar cfzp #{archive_path} #{service}")
    end

    DockerServices.Runner.start
  end

  def restore(service, archive_path) do
    DockerServices.Runner.stop

    with_progressbar "restore #{service} from #{archive_path}", "#{service} restored", fn ->
      DockerServices.Shell.run!("sudo rm -rf #{data_root_path}/#{service}; sudo mkdir -p #{data_root_path}")
      DockerServices.Shell.run!("cd #{data_root_path} && sudo tar xfz #{archive_path}")
    end

    DockerServices.Runner.start
  end

  defp with_progressbar(text, done, callback), do: DockerServices.WithProgressBar.run(text, done, callback)
  defp data_root_path, do: DockerServices.Paths.project_data_root
end
