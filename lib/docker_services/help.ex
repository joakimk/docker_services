defmodule DockerServices.Help do
  def show do
    IO.puts """
    docker_services v#{DockerServices.Version.current}

    Starts services (like redis, memcached, postgres) using docker.

    It sets environment variables for ports (ex: $REDIS_PORT) and ensures
    the data generated by the services are persisted (within ~/.docker_services).

    You can find available service images on dockerhub, ex:
    https://hub.docker.com/_/redis/

    Usage:
      cd project
      docker_services start
      docker_services stop

    For more information see https://github.com/joakimk/docker_services
    """
  end
end