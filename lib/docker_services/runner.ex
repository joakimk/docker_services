defmodule DockerServices.Runner do
  def with_services_stopped(callback) do
    stop
    callback.()
    start
  end

  def start do
    for_each_service &start/2
  end

  def stop do
    for_each_service &stop/2
  end

  defp for_each_service(callback) do
    project_config.docker_services
    |> Enum.map(fn {name, %{ image: image }} ->
      callback.(name, image)
    end)
    |> set_shell_environment
  end

  defp start(name, docker_image) do
    {:ok, external_port} =
      with_progressbar "starting #{name}", "#{name} running", fn ->
        docker_service.start(name, docker_image)
      end

    {name, docker_image, external_port}
  end

  defp stop(name, docker_image) do
    :ok =
      with_progressbar "stopping #{name}", "#{name} stopped", fn ->
        docker_service.stop(name)
      end

    {name, docker_image, :reset}
  end

  defp with_progressbar(text, done, callback), do: DockerServices.WithProgressBar.run(text, done, callback)

  defp set_shell_environment(services) do
    services
    |> Enum.flat_map(&build_environment/1)
    |> Enum.into(%{})
    |> DockerServices.ShellEnvironment.set
  end

  def build_environment({name, docker_image, external_port}) do
    [
      { "#{String.upcase(Atom.to_string(name))}_PORT", external_port }
    ] ++ DockerServices.CustomEnvironment.build(image_type(docker_image), external_port)
  end

  defp image_type(docker_image), do: docker_image |> String.split(":") |> hd |> String.to_atom

  defp docker_service, do: Application.get_env(:docker_services, :docker_client)
  defp project_config, do: DockerServices.ProjectConfig.load
end
