defmodule DockerServices.Docker do
  def start(name, docker_image) do
    docker "rm #{docker_name(name)}"
    docker "run --detach --name #{docker_name(name)} --publish #{internal_port(docker_image)} #{volume_mounts(name, docker_image) |> Enum.join(" ")} #{docker_image}"

    external_port = -1
    {:ok, external_port}
  end

  def stop(name) do
    docker "stop #{docker_name(name)}"

    :ok
  end

  defp docker(command) do
    IO.puts "Command to run: sudo docker " <> command
  end

  defp volume_mounts(name, docker_image) do
    metadata(docker_image).volumes
    |> Enum.map fn volume ->
      name = Atom.to_string(name)
      "-v #{Path.join([project_data_root, name, volume])}:#{volume}"
    end
  end

  defp internal_port(docker_image) do
    metadata(docker_image).internal_port
  end

  defp metadata(docker_image) do
    DockerServices.Shell.run("sudo docker inspect #{docker_image}")
    |> DockerServices.DockerMetadata.build
  end

  defp docker_name(name), do: DockerServices.Project.identifier <> "-" <> Atom.to_string(name)
  defp project_data_root, do: DockerServices.Paths.project_data_root
end