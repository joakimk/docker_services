defmodule DockerServicesTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest DockerServices

  test "'bootstrap' generates a shell file" do
    File.rm("tmp/shell")

    output = capture_io fn ->
      DockerServices.CLI.main([ "bootstrap" ])
    end

    assert output =~ "Bootstrap complete"

    { :ok, content } = File.read("tmp/shell")
    assert content =~ "function docker_services()"
  end

  #test "'start' starts the services specified in config" do
  #  # WIP

  #  File.rm_rf("tmp/test_project")
  #  File.mkdir_p("tmp/test_project")
  #  File.cd("tmp/test_project")
  #  File.write("dev.yml", """
  #  docker_services:
  #    redis:
  #      image: redis:2.8
  #  """)

  #  # docker = Application.get_env(:docker_services, :docker_client)
  #  #{:ok, external_port} = docker.start(name: name, image_name: image_name)
  #  # write port to file, etc.
  #  #:ok = docker.stop(name)

  #  output = capture_io fn ->
  #    DockerServices.CLI.main([ "start" ])
  #  end

  #  { :ok, content } = File.read("~/.docker_services/something/env.load")
  #  assert content == "export REDIS_PORT=5555"
  #:os.getenv [ 'a=b', '', ...

  # on start:
  # unload.env:
  # - for all env names we add:
  #   - if they already exist, write an export statement for the current value
  #   - if they don't exist, write an unset statement
  # load.env:
  # - for all env names we add:
  #   - write export statements

  # on stop:
  # load.env:
  # - copy unload.env

  # after commands run or on cd:
  # source ~/.docker_services/envs/$OLDPWD/unload.env
  # source ~/.docker_services/envs/$PWD/load.env
  #end

  test "'help' shows help text" do
    output = capture_io fn ->
      DockerServices.CLI.main([ "help" ])
    end

    assert output =~ "Usage:"
  end

  test "unknown commands shows that they are unknown and also shows the help text" do
    output = capture_io fn ->
      DockerServices.CLI.main([ "unknown1" ])
    end

    assert output =~ "Unknown command"
    assert output =~ "unknown1"
    assert output =~ "Usage:"
  end
end
