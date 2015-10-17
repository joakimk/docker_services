defmodule DockerServices do
  # Capture version as compile time as mix isn't available at runtime
  @version Mix.Project.config[:version]
  def version, do: @version
end
