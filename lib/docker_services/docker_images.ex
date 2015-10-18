defmodule DockerServices.DockerImages do
  def parse(output) do
    output
    |> String.split("\n")
    |> Enum.filter(fn line -> !String.contains?(line,"TAG") end)
    |> Enum.map(fn line -> String.split(line) |> Enum.take(2) end)
    |> Enum.filter(fn parts -> parts != [] end)
    |> Enum.map(fn [name, version] -> "#{name}:#{version}" end)
  end
end
