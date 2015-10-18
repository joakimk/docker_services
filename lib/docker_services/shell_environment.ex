defmodule DockerServices.ShellEnvironment do
  def set(new_environmoent_variables) do
    write_load_file new_environmoent_variables
    write_unload_file new_environmoent_variables
  end

  defp write_load_file(new_environment_variables) do
    File.mkdir_p(project_envs_path)
    File.write Path.join(project_envs_path, "load.env"), export_lines(new_environment_variables)
    new_environment_variables
  end

  defp write_unload_file(new_environment_variables) do
    File.mkdir_p(project_envs_path)
    File.write Path.join(project_envs_path, "unload.env"), unset_lines(new_environment_variables)
    new_environment_variables
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

  defp project_envs_path, do: DockerServices.Config.project_envs_path
end
