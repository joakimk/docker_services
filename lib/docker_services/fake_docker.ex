defmodule DockerServices.FakeDocker do
  def start(name, docker_image) do
    agent |> Agent.update fn (state) -> %{ command: :start, name: name, docker_image: docker_image } end

    {:ok, 5555}
  end

  def stop(name) do
    agent |> Agent.update fn (state) -> %{ command: :stop, name: name } end

    :ok
  end

  def last_command do
    agent |> Agent.get fn (state) -> state end
  end

  # TODO: find a simpler way of keeping global state for fakes
  defp agent, do: Process.whereis(__MODULE__) |> agent
  defp agent(nil) do
    {:ok, pid} = Agent.start_link fn -> %{} end, name: __MODULE__
    pid
  end
  defp agent(pid), do: pid
end
