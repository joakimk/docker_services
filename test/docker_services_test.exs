defmodule DockerServicesTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest DockerServices

  setup do
    File.cd(root_path)
    File.rm_rf("tmp/docker_services")
    System.put_env("PWD", System.cwd)
    :ok
  end

  test "'bootstrap' generates a shell file" do
    output = capture_io fn ->
      DockerServices.CLI.main([ "bootstrap" ])
    end

    assert output =~ "Bootstrap complete"

    { :ok, content } = File.read("tmp/docker_services/shell")
    assert content =~ "function docker_services()"
  end

  test "'start' starts the services specified in config" do
    File.rm_rf("tmp/test_project")
    File.mkdir_p("tmp/test_project")
    File.write "tmp/test_project/dev.yml", """
    docker_services:
      redis:
        image: redis:2.8
      postgres:
        image: postgres:9.3.5
    """

    System.put_env("REDIS_PORT", "9999")

    output = capture_io fn ->
      File.cd("tmp/test_project")
      System.put_env("PWD", System.cwd)
      DockerServices.CLI.main([ "start" ])
    end

    assert output =~ "Starting redis:2.8... done"

    # the new environment we want after running this command:
    { :ok, content } = File.read("#{root_path}/tmp/docker_services/envs/#{root_path}/tmp/test_project/load.env")
    assert content =~ "export REDIS_PORT=5555"
    assert content =~ "export POSTGRES_PORT=5555"
    assert content =~ "export PGPORT=5555"

    # TODO: write unsets/resets code, currently stubbed as unset to try it out

    ### unload.env restores the environment as it was before load.env changed it:
    #{ :ok, content } = File.read("#{System.get_env("HOME")}/.docker_services/projects/#{project_identifier}/unload.env")
    #assert content == "export REDIS_PORT=9999"

    #assert FakeDocker.last_command == %{ command: start, name: "redis", docker_image: "redis:2.8" }

    # on start:
    # unload.env:
    # - for all env names we add:
    #   - if they already exist, write an export statement for the current value
    #   - if they don't exist, write an unset statement
    # load.env:
    # - for all env names we add:
    #   - write export statements
  end

  @root_path System.cwd
  defp root_path, do: @root_path


  #  # docker = Application.get_env(:docker_services, :docker_client)
  #  #{:ok, external_port} = docker.start(name: name, image_name: image_name)
  #  # write port to file, etc.
  #  #:ok = docker.stop(name)
  #:os.getenv [ 'a=b', '', ...

  # on stop:
  # load.env:
  # - copy unload.env

  # after commands run or on cd:
  # source ~/.docker_services/envs/$OLDPWD/unload.env
  # source ~/.docker_services/envs/$PWD/load.env

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
