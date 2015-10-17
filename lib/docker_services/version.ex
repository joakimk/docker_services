defmodule DockerServices.Version do
  @version Mix.Project.config[:version]

  def current do
    @version
  end
end
