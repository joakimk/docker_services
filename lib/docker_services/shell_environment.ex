defmodule DockerServices.ShellEnvironment do
  def set(envs) do
    write_load_file envs
    write_unload_file envs
  end

  defp write_load_file(envs) do
    write_env_file(envs, "load", &build_load_lines/1)
  end

  defp write_unload_file(envs) do
    write_env_file(envs, "unload", &build_unload_lines/1)
  end

  def write_env_file(envs, type, formatter) do
    File.mkdir_p(project_envs_path)
    File.write(Path.join(project_envs_path, "#{type}.env"), formatter.(envs))
  end

  defp build_load_lines(envs) do
    envs
    |> Enum.map(fn ({ name, value }) -> "export #{name}=#{value}" end)
    |> Enum.join("\n")
  end

  defp build_unload_lines(envs) do
    envs
    |> Enum.map(fn ({ name, _value }) ->
      existing_value = System.get_env(name)

      if existing_value do
        "export #{name}=#{existing_value}"
      else
        "unset #{name}"
      end
    end)
    |> Enum.join("\n")
  end

  defp project_envs_path, do: DockerServices.Paths.project_envs_path
end
