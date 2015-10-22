defmodule DockerServices.Backup do
  def backup(service, archive_path) do
    with_services_stopped fn ->
      with_progressbar "backing up #{service} to #{archive_path}", "#{service} backed up to #{archive_path}", fn ->
        DockerServices.Shell.run!("cd #{data_root_path} && tar cfzp #{archive_path} #{service}")
      end
    end
  end

  def restore(service, archive_path) do
    with_services_stopped fn ->
      with_progressbar "restore #{service} from #{archive_path}", "#{service} restored", fn ->
        DockerServices.Shell.run!("sudo rm -rf #{data_root_path}/#{service}; sudo mkdir -p #{data_root_path}")
        DockerServices.Shell.run!("cd #{data_root_path} && sudo tar xfz #{archive_path}")
      end
    end
  end

  defp with_services_stopped(callback), do: DockerServices.Runner.with_services_stopped(callback)
  defp with_progressbar(text, done, callback), do: DockerServices.WithProgressBar.run(text, done, callback)
  defp data_root_path, do: DockerServices.Paths.project_data_root
end
