defmodule DockerServices.Docker do
  def start(name, docker_image) do
    installed_images = DockerServices.DockerImages.parse(DockerServices.Shell.run("sudo docker images list"))
    unless Enum.member?(installed_images, docker_image) do
      docker "pull #{docker_image}"
    end

    docker "rm #{docker_name(name)}"
    docker "run --detach --name #{docker_name(name)} --publish #{internal_port(docker_image)} #{volume_mounts(name, docker_image) |> Enum.join(" ")} #{docker_image}"

    external_port = metadata(docker_name(name)).external_port
    {:ok, external_port}
  end

  def stop(name) do
    docker "stop #{docker_name(name)}"

    :ok
  end

  defp docker(command) do
    # TODO: handle exit status
    result = DockerServices.Shell.run("sudo docker " <> command)

    if result =~ "Error" do
      IO.puts result
      System.halt(1)
    end
  end

  defp volume_mounts(name, docker_image) do
    metadata(docker_image).volumes
    |> Enum.map fn volume ->
      name = Atom.to_string(name)
      "-v #{Path.join([project_data_root, name, volume])}:#{volume}"
    end
  end

  defp internal_port(identifier) do
    metadata(identifier).internal_port
  end

  defp metadata(identifier) do
    DockerServices.Shell.run("sudo docker inspect #{identifier}")
    |> DockerServices.DockerMetadata.build
  end

  defp docker_name(name), do: DockerServices.Project.identifier <> "-" <> Atom.to_string(name)
  defp project_data_root, do: DockerServices.Paths.project_data_root
end
