defmodule DockerServices.Config do
  def shell_file_path do
    Path.join(data_root_path, "shell")
  end

  defp data_root_path do
    Application.get_env(:docker_services, :data_root_path)
    |> String.replace("HOME_PATH", System.get_env("HOME"))
  end
end
