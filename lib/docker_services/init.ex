defmodule DockerServices.Init do
  def run do
    create_home_directory
    write_shell_script
  end

  defp create_home_directory do
    shell_file_path
    |> Path.dirname
    |> File.mkdir_p
  end

  defp write_shell_script do
    File.write shell_file_path, """
    function docker_services() {
      if [ "$1" == "set_environment_variables" ]; then
        # docker_services will set envs here later without running any elixir code
        # as that is a bit too slow to do while navigating the filesystem
        echo "" > /dev/null
      else
        /usr/local/bin/docker_services $@
      fi

      # Reload this script after init has been run since it might have changed
      if [ "$1" == "init" ]; then
        source "#{shell_file_path}"
      fi
    }
    """
  end

  defp shell_file_path do
    Application.get_env(:docker_services, :shell_file_path)
    |> String.replace("HOME_PATH", System.get_env("HOME"))
  end
end
