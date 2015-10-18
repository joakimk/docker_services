defmodule DockerServices.Config do
  def shell_file_path do
    Path.join(data_root_path, "shell")
  end

  def project_envs_path do
    # Must be the env PWD to match the shell scripts written by DockerServices.Bootstrap
    envs_pwd = System.get_env("PWD")

    Path.join(envs_path, envs_pwd)
  end

  def envs_path do
    Path.join(data_root_path, "envs")
  end

  def project_path do
    Path.join([data_root_path, "projects", project_identifier])
  end

  defp project_identifier, do: DockerServices.Project.identifier

  defp data_root_path do
    Application.get_env(:docker_services, :data_root_path)
    |> String.replace("HOME_PATH", System.get_env("HOME"))
  end
end
