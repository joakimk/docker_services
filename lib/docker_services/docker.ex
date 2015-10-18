defmodule DockerServices.Docker do
  def start(name, docker_image) do
    IO.puts "Start: doing nothing yet"

    external_port = -1
    {:ok, external_port}
  end

  def stop(name) do
    IO.puts "Stop: doing nothing yet"

    :ok
  end
end
