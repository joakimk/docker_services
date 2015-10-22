defmodule DockerServices.ShellTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias DockerServices.Shell

  # Reset pwd as this test relies on it
  @pwd System.cwd
  setup do: File.cd(@pwd)

  test "silently runs commands and returns status and both stdout and stderr output" do
    { :ok, output, exit_status } = Shell.run("ls")
    assert exit_status == 0
    assert output =~ "README.md"

    { :error, output, exit_status } = Shell.run("unknown_command")
    assert exit_status == 127
    assert output =~ "not found"
  end

  test "can show output" do
    output = capture_io fn ->
      { :ok, _, _ } = Shell.run("ls", silent: false)
    end

    assert output =~ "README.md"
  end

  test "raises on errors when bang version is used" do
    assert_raise RuntimeError, ~r{unknown_command.+failed.+exit status 127},  fn ->
      Shell.run!("unknown_command")
    end
  end

  test "returns only output when bang version is used" do
    output = Shell.run!("ls")

    assert output =~ "README.md"
  end

  test "can run multiple commands" do
    output = Shell.run!("echo 'hello'; ls")

    assert output =~ "hello"
    assert output =~ "README.md"
  end
end
