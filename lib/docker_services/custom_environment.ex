defmodule DockerServices.CustomEnvironment do
  @moduledoc """
  Used to customize environment variables for specific services.

  For example, postgres command line tools like psql can use the PGPORT
  envs to connect to a custom port. By setting it, you can use the
  docker postgres server just as if it was installed into the system.
  """

  def build(:postgres, external_port) do
    [
      { "PGPORT", external_port }
    ]
  end

  def build(_name, _external_port), do: []
end
