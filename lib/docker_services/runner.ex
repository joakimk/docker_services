defmodule DockerServices.Runner do
  def start do
    start_services
    set_shell_environment
  end

  defp start_services do
    project_config.docker_services
    |> Enum.each fn {name, %{ image: image }} ->
      start_docker_service(name, image)
    end
  end

  defp set_shell_environment do
    project_config.docker_services
    |> Enum.map(fn {name, _} ->
      { "#{String.upcase(Atom.to_string(name))}_PORT", "5555" }
    end)
    |> Enum.into(%{})
    |> DockerServices.ShellEnvironment.set
  end

  defp start_docker_service(name, docker_image) do
    IO.write "Starting #{docker_image}... "
    IO.puts "done"
  end

  defp project_config, do: DockerServices.ProjectConfig.load
end
