defmodule DockerServices.Shell do
  def run(command) do
    :os.cmd(command |> String.to_char_list) |> List.to_string
  end
end
