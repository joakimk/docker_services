defmodule DockerServices.Mixfile do
  use Mix.Project

  def project do
    [app: :docker_services,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [
       main_module: DockerServices.CLI
     ],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :yaml_elixir],
      env: [
        data_root_path: "HOME_PATH/.docker_services",
        docker_client: DockerServices.Docker,
      ],
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      { :yaml_elixir, github: "KamilLelonek/yaml-elixir" },
      { :yamerl, github: "yakaz/yamerl" },
      { :poison, "~> 1.5" },
    ]
  end
end
