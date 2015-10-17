# NOTE: Readme driven development below, this means this tool does not necessarily do what it says below yet.

**Status**: just starting out

## What is this?

A tool to run multiple versions of services like redis or postgres on the same computer without having port collisions using docker.

## Motivation

We've been using tools like this at [auctionet.com](http://dev.auctionet.com) with great success for more than a year. It has enabled us to develop many small and big projects in a single vagrant VM. Even if vagrant is great for isolating projects, sometimes it's a bit heavyweight.

I've tried to release this as part of a [bigger project](https://github.com/joakimk/devbox-tools) before, but have realised that it has value as a stand alone tool.

## Prerequisites

* Erlang 18 or newer, see <https://www.erlang-solutions.com/downloads/download-erlang-otp>
* docker, see <https://www.docker.com/>

## Installation

    sudo curl -L https://github.com/joakimk/docker_services/releases/download/v0.1/docker_services \
            > /usr/local/bin/docker_services && \
            sudo chmod +x /usr/local/bin/docker_services && \
            docker_services init

## Hooking into "cd"

This tool relies on being able to change environment variables when you change directories, so it needs to hook into `cd`. However, it's fairly common for tools to redefine `cd`, and it can only be overriden once.

So first check what your `cd` does:

    $ type cd

If it says "cd is a shell builtin", then add this to your profile:

    if [ -s "$HOME/.docker_services/shell" ]; then
      source ~/.docker_services/shell

      cd ()
      {
          if builtin cd "$@"; then
              docker_services set_environment_variables
              return 0;
          else
              return $?;
          fi
      }
    fi

If it says "cd is a function", then copy that existing function and add `docker_services set_environment_variables`.

## Usage

### Configure the project

    $ cd project
    $ printf "docker_services:\n  redis:\n    image: redis:2.8\n" > dev.yml

### Start services

    $ docker_services start
    Installing service: redis:2.8... done
    Starting service: redis:2.8... done

    $ redis-cli -p $REDIS_PORT
    127.0.0.1:1234>

### Stopping services

    $ docker_services stop
    Stopping service: redis:2.8... done

### How environment variables are handled

Environment variables are automatically set and cleared using a "cd" hook:

    $ cd project_already_using_docker_services

    $ export | grep PORT
    REDIS_PORT=1234

    $ cd ..

    $ export | grep PORT

## Where is data stored?

Data is stored ourside of docker in `~/.docker_services/project_identifier/service_name`. The path is mounted as a volume within the docker service when it's run.

# Development

    mix deps.get
    mix test

    # mix escript.build
    # scp docker_services test_server:/usr/local/bin

# Release

1) Build script:

    MIX_ENV=prod mix escript.build

2) Go to https://github.com/joakimk/docker_services/releases and make a release.

3) Update install instructions in [readme](https://github.com/joakimk/docker_services/edit/master/README.md).
