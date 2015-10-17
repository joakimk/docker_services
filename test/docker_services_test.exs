defmodule DockerServicesTest do
  use ExUnit.Case
  doctest DockerServices

  test "init generates a shell file" do
    File.rm("tmp/shell")
    DockerServices.CLI.main([ "init" ])

    { :ok, content } = File.read("tmp/shell")
    assert content =~ "function docker_services()"
  end
end
