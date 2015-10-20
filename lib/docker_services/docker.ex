# NOTE: This module is not tested by the automatic test suite. So far, manual testing has worked out. Automating this would probably require spinning up a vagrant VM and running docker within it, etc.

defmodule DockerServices.Docker do
  alias DockerServices.Shell

  def start(name, docker_image) do
    pull_docker_image_if_needed(docker_image)

    unless running?(name) do
      # It's okay if this command fails, it will do that the first time when there is no image to remove, but we still have to try since run will refuse to run otherwise.
      Shell.run "sudo docker rm #{docker_name(name)}"

      docker "run --detach --name #{docker_name(name)} --publish #{internal_port(docker_image)} #{volume_mounts(name, docker_image) |> Enum.join(" ")} #{docker_image}"
    end

    {:ok, external_port(name)}
  end

  def stop(name) do
    if running?(name), do: docker "stop #{docker_name(name)}"

    :ok
  end

  defp pull_docker_image_if_needed(docker_image) do
    unless Enum.member?(installed_images, docker_image) do
      IO.puts "\n\nPulling docker image for #{docker_image}..."
      docker "pull #{docker_image}", silent: false
      IO.puts ""
    end
  end

  defp installed_images do
    Shell.run!("sudo docker images")
    |> DockerServices.DockerImages.parse
  end

  defp running?(name) do
    result = Shell.run("sudo docker ps | grep #{docker_name(name)}")
    elem(result, 0) == :ok
  end

  defp docker(command), do: docker(command, silent: true)
  defp docker(command, silent: silent) do
    Shell.run!("sudo docker " <> command, silent: silent)
  end

  defp volume_mounts(name, docker_image) do
    metadata(docker_image).volumes
    |> Enum.map fn volume ->
      name = Atom.to_string(name)
      "-v #{Path.join([project_data_root, name, volume])}:#{volume}"
    end
  end

  defp internal_port(identifier), do: metadata(identifier).internal_port
  defp external_port(name),       do: metadata(docker_name(name)).external_port

  defp metadata(identifier) do
    Shell.run!("sudo docker inspect #{identifier}")
    |> DockerServices.DockerMetadata.build
  end

  defp docker_name(name), do: DockerServices.Project.identifier <> "-" <> Atom.to_string(name)
  defp project_data_root, do: DockerServices.Paths.project_data_root
end
