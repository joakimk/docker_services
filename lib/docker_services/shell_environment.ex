defmodule DockerServices.ShellEnvironment do
  def set(envs) do
    write_load_file envs
    write_unload_file envs
  end

  defp write_load_file(envs) do
    write_env_file(envs, "load", &export_lines/1)
  end

  defp write_unload_file(envs) do
    write_env_file(envs, "unload", &unset_lines/1)
  end

  def write_env_file(envs, type, formatter) do
    File.mkdir_p(project_envs_path)
    File.write(Path.join(project_envs_path, "#{type}.env"), formatter.(envs))
  end

  defp export_lines(envs) do
    envs
    |> Enum.map(fn ({ name, value }) -> "export #{name}=#{value}" end)
    |> Enum.join("\n")
  end

  defp unset_lines(envs) do
    envs
    |> Enum.map(fn ({ name, _value }) -> "unset #{name}" end)
    |> Enum.join("\n")
  end

  defp project_envs_path, do: DockerServices.Paths.project_envs_path
end