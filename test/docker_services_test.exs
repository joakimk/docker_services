defmodule DockerServicesTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest DockerServices

  setup do
    File.cd(root_path)
    File.chmod("tmp/docker_services", 755)
    File.rm_rf("tmp/docker_services")
    File.rm_rf("tmp/backup.tar.gz")
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
    assert content =~ "export REDIS_PORT=21000"
    assert content =~ "export POSTGRES_PORT=20000"
    assert content =~ "export PGPORT=20000"

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

  test "can have multiple services of the same type" do
    File.rm_rf("tmp/test_project")
    File.mkdir_p("tmp/test_project")
    File.write "tmp/test_project/dev.yml", """
    docker_services:
      redis1:
        image: redis:2.8
      redis2:
        image: redis:2.8
    """

    ## Starting

    output = capture_io fn ->
      File.cd("tmp/test_project")
      System.put_env("PWD", System.cwd)
      DockerServices.CLI.main([ "start" ])
    end

    assert output =~ "starting redis1"
    assert output =~ "starting redis2"

    { :ok, content } = File.read("#{root_path}/tmp/docker_services/envs/#{root_path}/tmp/test_project/load.env")
    assert content =~ "export REDIS1_PORT=21001"
    assert content =~ "export REDIS2_PORT=21002"

    # Sets custom ports from the last of a type
    assert content =~ "export REDIS_PROVIDER=redis://127.0.0.1:21002"

    assert DockerServices.FakeDocker.last_command == %{ command: :start, name: :redis2, docker_image: "redis:2.8" }
  end

  test "'backup' and 'restore' creates and restores data from tar.gz" do
    File.rm_rf("tmp/test_project")
    File.mkdir_p("tmp/test_project")
    File.write "tmp/test_project/dev.yml", """
    docker_services:
      redis:
        image: redis:2.8
    """

    File.cd("tmp/test_project")
    pwd = System.cwd
    System.put_env("PWD", pwd)
    file_from_backup_path = "#{DockerServices.Paths.project_data_root}/redis/file_from_backup"
    File.mkdir_p(file_from_backup_path)

    command_output = capture_io fn ->
      # Backup
      DockerServices.CLI.main([ "backup", "redis", "#{root_path}/tmp/backup.tar.gz" ])
      File.rm_rf(file_from_backup_path)
      refute File.exists?(file_from_backup_path)

      # Restore
      DockerServices.CLI.main([ "restore", "redis", "#{root_path}/tmp/backup.tar.gz" ])
      assert File.exists?(file_from_backup_path)
    end

    assert command_output =~ "backing up redis"
    assert command_output =~ "redis restored"

    # Check the contents of the file
    File.cd("#{root_path}/tmp")
    { :ok, tar_output, 0 } = DockerServices.Shell.run("tar xvfz backup.tar.gz")
    assert tar_output =~ "redis/file_from_backup"

    # Remove files on disk and restore (e.g. test fresh install from backup)
    { :ok, _ } = File.rm_rf(DockerServices.Paths.project_data_root)

    File.cd("#{root_path}/tmp/test_project")

    capture_io fn ->
      DockerServices.CLI.main([ "stop" ])
      DockerServices.CLI.main([ "restore", "redis", "#{root_path}/tmp/backup.tar.gz" ])
    end

    assert File.exists?(file_from_backup_path)
  end

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
