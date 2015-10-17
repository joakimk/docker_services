defmodule DockerServices.Config do
  def load do
    YamlElixir.read_from_file("dev.yml")
    |> convert_keys_to_atoms
  end

  defp convert_keys_to_atoms(map) when is_map(map) do
    map
    |> Enum.map(fn {key, value} ->
      { String.to_atom(key), convert_keys_to_atoms(value) }
    end)
    |> Enum.into(%{})
  end

  defp convert_keys_to_atoms(value) do
    value
  end
end
