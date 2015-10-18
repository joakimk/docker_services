defmodule DockerServices.Docker do
  alias DockerServices.Shell

  def start(name, docker_image) do
    installed_images = DockerServices.DockerImages.parse(Shell.run!("sudo docker images"))
    unless Enum.member?(installed_images, docker_image) do
      IO.puts "\n\nPulling docker image for #{docker_image}..."
      docker "pull #{docker_image}", silent: false
      IO.puts ""
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


  defp docker(command), do: docker(command, silent: true)
  defp docker(command, silent: silent) do
    # TODO: handle exit status
    result = Shell.run!("sudo docker " <> command, silent: silent)

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
    Shell.run!("sudo docker inspect #{identifier}")
    |> DockerServices.DockerMetadata.build
  end

  defp docker_name(name), do: DockerServices.Project.identifier <> "-" <> Atom.to_string(name)
  defp project_data_root, do: DockerServices.Paths.project_data_root
end
