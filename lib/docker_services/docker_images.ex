defmodule DockerServices.DockerImages do
  def parse(output) do
    output
    |> String.split("\n")
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&ignore?/1)
    |> Enum.map(&name_and_version/1)
  end

  defp parse_line(line) do
    line
    |> String.split
    |> Enum.take(2)
  end

  defp ignore?([ "REPOSITORY", _ ]), do: true
  defp ignore?([]), do: true
  defp ignore?(_),  do: false

  def name_and_version([name, version]) do
    "#{name}:#{version}"
  end
end
