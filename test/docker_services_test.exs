defmodule DockerServicesTest do
  use ExUnit.Case
  doctest DockerServices

  test "bootstrap generates a shell file" do
    File.rm("tmp/shell")

    DockerServices.CLI.main([ "bootstrap" ])

    { :ok, content } = File.read("tmp/shell")
    assert content =~ "function docker_services()"
  end
end
