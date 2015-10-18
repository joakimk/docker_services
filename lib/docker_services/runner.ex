defmodule DockerServices.Runner do
  def start do
    project_config.docker_services
    |> Enum.each fn {name, %{ image: image }} ->
      start(name, image)
    end
  end

  def start(name, docker_image) do
    IO.write "Starting #{docker_image}... "
    new_envs = %{ "REDIS_PORT" => "5555" }
    DockerServices.ShellEnvironment.set(new_envs)
    IO.puts "done"
  end

  defp project_config, do: DockerServices.ProjectConfig.load
end
