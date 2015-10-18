defmodule DockerServices.Bootstrap do
  def run do
    create_home_directory
    write_shell_script
    IO.puts "Bootstrap complete, now go read: https://github.com/joakimk/docker_services#hooking-into-cd"
  end

  defp create_home_directory do
    shell_file_path
    |> Path.dirname
    |> File.mkdir_p
  end

  defp write_shell_script do
    File.write shell_file_path, """
    function docker_services() {
      /usr/local/bin/docker_services $@
      exit_status=$?

      # Reload this script after bootstrap has been run since it might have changed
      if [ "$1" == "bootstrap" ]; then
        source "#{shell_file_path}"
      fi

      return $exit_status
    }

    function __docker_services_set_environment_variables()
    {
      # docker_services will set envs here later without running any elixir code
      # as that is a bit too slow to do while navigating the filesystem
      echo "" > /dev/null # bash needs at least one line of code here... :(
    }
    """
  end

  defp shell_file_path, do: DockerServices.Config.shell_file_path
end
