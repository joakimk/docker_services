defmodule DockerServices.CustomEnvironment do
  @moduledoc """
  Used to customize environment variables for specific services.

  For example, postgres command line tools like psql can use the PGPORT
  env to connect to a custom port. By setting it, you can use the
  docker postgres server just as if it was installed into the system.
  """

  def build(:postgres, external_port) do
    [
      { "PGPORT", external_port },
      { "PGHOST", "localhost "},
      { "PGUSER", "postgres "},
    ]
  end

  def build(_name, _external_port), do: []
end
