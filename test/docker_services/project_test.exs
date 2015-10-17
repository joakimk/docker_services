defmodule DockerServices.ProjectTest do
  use ExUnit.Case

  test "identifier: generates an identifier based on the current directory" do
    assert DockerServices.Project.identifier == DockerServices.Project.identifier

    old_identifier = DockerServices.Project.identifier
    File.mkdir_p("/tmp/test_path")
    File.cd("/tmp/test_path")
    assert old_identifier != DockerServices.Project.identifier

    assert DockerServices.Project.identifier =~ "test-path-"
  end
end
