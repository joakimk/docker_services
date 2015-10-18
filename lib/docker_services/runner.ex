defmodule DockerServices.Runner do
  def start do
    start_services
    |> set_shell_environment
  end

  defp start_services do
    project_config.docker_services
    |> Enum.map(fn {name, %{ image: image }} ->
      start_docker_service(name, image)
    end)
  end

  defp start_docker_service(name, docker_image) do
    IO.write "Starting #{docker_image}... "
    IO.puts "done"

    external_port = 5555
    {name, external_port}
  end

  defp set_shell_environment(services) do
    services
    |> Enum.flat_map(fn {name, external_port} ->
      build_environment(name, external_port)
    end)
    |> Enum.into(%{})
    |> DockerServices.ShellEnvironment.set
  end

  def build_environment(name, external_port) do
    [
      { "#{String.upcase(Atom.to_string(name))}_PORT", external_port }
    ] ++ DockerServices.CustomEnvironment.build(name, external_port)
  end

  defp project_config, do: DockerServices.ProjectConfig.load
end
