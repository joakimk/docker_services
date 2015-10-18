defmodule DockerServices.DockerMetadata do
  defstruct internal_port: :unknown, external_port: :unknown, volumes: []

  def build(json) do
    [ data ] = JSON.parse(json)

    %__MODULE__{
      internal_port: internal_port(data),
      external_port: external_port(parse_network_port(data)),
      volumes: volumes(data)
    }
  end

  defp parse_network_port(%{ "NetworkSettings" => %{ "Ports" => port_info } }), do: Map.values(port_info)
  defp parse_network_port(_), do: nil

  # really wish I could pattern match on map keys, I think this will be possible in elixir 1.2
  defp external_port([[ %{ "HostPort" => port } ]]), do: String.to_integer(port)
  defp external_port(_), do: :unknown

  def internal_port(data) do
    data["Config"]["ExposedPorts"]
      |> Map.keys |> hd
      |> String.split("/tcp") |> hd
      |> String.to_integer
  end

  def volumes(data) do
    (data["Config"]["Volumes"] || %{}) |> Map.keys
  end
end
