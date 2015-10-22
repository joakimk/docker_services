# This is a small shell command library that does what you want in these kinds of scripts:
# * Keep output hidden unless there is an error.
# * Raise good error messages when there is an error.
# * Show output while the command is running when requested.
# * Capture output and merge stdout with stderr.
# * Be able to ignore errors.

# Might extract this to a hex package later.

defmodule DockerServices.Shell do
  def run!(command), do: run!(command, silent: true)
  def run!(command, silent: silent) do
    result = run(command, silent: silent)

    case result do
      {:ok, output, exit_status} ->
        output
      {:error, output, exit_status} ->
        raise "Command '#{command}' failed with exit status #{exit_status}.\n\nCommand output:\n\n#{output}"
      other ->
        raise "Unexpected result: #{result.inspect}"
    end
  end

  @env Mix.env
  def run(command), do: run(command, silent: true)
  def run(command, silent: silent) do
    # sudo is needed to restore files with the right permissions and owners but
    # is unpractical to run in tests as a password prompt could lock up the test suite
    if @env == :test, do: command = String.replace(command, "sudo", "")
    command = "bash -c '#{command}'"

    port = Port.open({:spawn, command}, [:stderr_to_stdout, :exit_status])

    {output, exit_status} = wait_for_command_to_finish(port, silent)

    if exit_status != 0 do
      {:error, output, exit_status}
    else
      {:ok, output, exit_status}
    end
  end

  defp wait_for_command_to_finish(port, silent), do: wait_for_command_to_finish(port, silent, "", nil)
  defp wait_for_command_to_finish(port, silent, output, nil) do
    exit_status = nil

    receive do
      { _, {:data, data}} ->
        output = output <> List.to_string(data)
        unless silent, do: IO.write data
      { _, {:exit_status, e}} ->
        exit_status = e
    end

    wait_for_command_to_finish(port, silent, output, exit_status)
  end

  defp wait_for_command_to_finish(port, silent, output, exit_status), do: {output, exit_status}
end
