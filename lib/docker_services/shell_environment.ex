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
    content = formatter.(envs)
    path = Path.join(project_envs_path, "#{type}.env")

    if content do
      File.mkdir_p(Path.dirname(path))
      File.write(path, formatter.(envs))
    else
      File.rm(path)
    end
  end

  defp build_load_lines(envs) do
    # TODO: implement this in a cleaner way
    if envs |> Enum.any?(fn {name, value} -> value == :reset end) do
      nil
    else
      envs
      |> Enum.map(fn ({ name, value }) -> "export #{name}=#{value}" end)
      |> Enum.join("\n")
    end
  end

  defp build_unload_lines(envs) do
    envs
    |> Enum.map(fn ({ name, _value }) -> "unset #{name}" end)
    |> Enum.join("\n")
  end

  defp project_envs_path, do: DockerServices.Paths.project_envs_path
end
