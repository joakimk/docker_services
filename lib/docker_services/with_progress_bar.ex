defmodule DockerServices.WithProgressBar do
  def run(text, done, callback) do
    ProgressBar.render_spinner [text: text, done: done, frames: :braille, spinner_color: IO.ANSI.blue], callback
  end
end
