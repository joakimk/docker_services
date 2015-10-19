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

  test "'bootstrap' has a helpful error message when it fails" do
    File.mkdir_p("tmp/docker_services")
    File.chmod("tmp/docker_services", 0)

    assert_raise RuntimeError, ~r{Could not write.+shell.+eacces}, fn ->
      DockerServices.CLI.main([ "bootstrap" ])
    end
  end

  test "'start' and 'stop' starts and stops the services specified in config" do
    File.rm_rf("tmp/test_project")
    File.mkdir_p("tmp/test_project")
    File.write "tmp/test_project/dev.yml", """
    docker_services:
      redis:
        image: redis:2.8
      postgres:
        image: postgres:9.3.5
    """

    ## Starting

    output = capture_io fn ->
      File.cd("tmp/test_project")
      System.put_env("PWD", System.cwd)
      DockerServices.CLI.main([ "start" ])
    end

    assert output =~ "starting redis"
    assert output =~ "starting postgres"

    # the new environment we want after running this command:
    { :ok, content } = File.read("#{root_path}/tmp/docker_services/envs/#{root_path}/tmp/test_project/load.env")
    assert content =~ "export REDIS_PORT=5555"
    assert content =~ "export POSTGRES_PORT=5555"
    assert content =~ "export PGPORT=5555"

    # unload.env restores the environment as it was before load.env changed it:
    { :ok, content } = File.read("#{root_path}/tmp/docker_services/envs/#{root_path}/tmp/test_project/unload.env")
    assert content =~ "unset REDIS_PORT"
    assert content =~ "unset POSTGRES_PORT"
    assert content =~ "unset PGPORT"

    assert DockerServices.FakeDocker.last_command == %{ command: :start, name: :redis, docker_image: "redis:2.8" }

    ## Stopping

    output = capture_io fn ->
      File.cd("tmp/test_project")
      System.put_env("PWD", System.cwd)
      DockerServices.CLI.main([ "stop" ])
    end

    assert output =~ "stopping redis"
    assert output =~ "stopping postgres"

    # no envs to load after stopping
    refute File.exists?("#{root_path}/tmp/docker_services/envs/#{root_path}/tmp/test_project/load.env")

    # but we do want to unload the envs we set previously
    { :ok, content } = File.read("#{root_path}/tmp/docker_services/envs/#{root_path}/tmp/test_project/unload.env")
    assert content =~ "unset REDIS_PORT"
    assert content =~ "unset POSTGRES_PORT"
    assert content =~ "unset PGPORT"

    assert DockerServices.FakeDocker.last_command == %{ command: :stop, name: :redis }
  end

  # test "'stop' when nothing is running does nothing"

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

  @root_path System.cwd
  defp root_path, do: @root_path
end
