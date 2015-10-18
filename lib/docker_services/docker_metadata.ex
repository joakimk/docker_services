defmodule DockerServices.DockerMetadata do
  defstruct internal_port: :unknown, external_port: :unknown, volumes: []

  def build(json) do
    [ data ] = JSON.parse(json)

    internal_port = data["Config"]["ExposedPorts"]
      |> Enum.map(fn {k, v} -> k end) |> hd
      |> String.split("/tcp") |> hd
      |> String.to_integer

    external_port = nil
    volumes = (data["Config"]["Volumes"] || %{})
      |> Enum.map(fn {k, v} -> k end)

    %__MODULE__{
      internal_port: internal_port,
      external_port: external_port,
      volumes: volumes
    }
  end
end
