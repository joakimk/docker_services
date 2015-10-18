defmodule DockerServices.Runner do
  def start do
    project_config.docker_services
    |> Enum.each fn {name, %{ image: image }} ->
      start(name, image)
    end
  end

  def start(name, docker_image) do
    IO.write "Starting #{docker_image}... "
    IO.puts "done"
  end

  defp project_config, do: DockerServices.ProjectConfig.load
end
