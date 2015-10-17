defmodule DockerServices.Project do
  def identifier do
    "#{project_name}-#{directory_hash}"
  end

  defp project_name, do: Path.basename(System.cwd) |> String.replace("_", "-")

  defp directory_hash do
    :crypto.hash(:sha, System.cwd)
    |> Base.encode16
    |> String.downcase
  end
end
