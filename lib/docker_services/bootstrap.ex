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

      if [ $exit_status == 0 ]; then
        __docker_services_set_environment_variables

        # Reload this script after bootstrap has been run since it might have changed
        if [ "$1" == "bootstrap" ]; then
          source "#{shell_file_path}"
        fi
      fi

      return $exit_status
    }

    function __docker_services_set_environment_variables()
    {
      [ -f #{envs_path}/$OLDPWD/unload.env ] && source #{envs_path}/$OLDPWD/unload.env
      [ -f #{envs_path}/$PWD/unload.env ]    && source #{envs_path}/$PWD/unload.env
      [ -f #{envs_path}/$PWD/load.env ]      && source #{envs_path}/$PWD/load.env
    }
    """
  end

  defp envs_path, do: DockerServices.Paths.envs_path
  defp shell_file_path, do: DockerServices.Paths.shell_file_path
end
