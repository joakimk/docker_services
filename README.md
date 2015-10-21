![](https://dl.dropboxusercontent.com/u/136929/docker_services_intro.gif)

## What is this?

A tool to install and run multiple versions of services like redis or postgres on the same computer without having port collisions by using docker.

## Motivation

We've been using tools like this at [dev.auctionet.com](http://dev.auctionet.com) successfully for more than a year. It has enabled us to develop many small and big projects in a single vagrant VM. Even if vagrant is great for isolating projects, sometimes it's a bit heavyweight.

I've tried to release this as part of a [bigger project](https://github.com/joakimk/devbox-tools) before, but have realised that it has value as a stand alone tool.

## Prerequisites

* Erlang 18 or newer, see <https://www.erlang-solutions.com/downloads/download-erlang-otp>
* docker, see <https://www.docker.com/>

## Installation

    curl -L https://github.com/joakimk/docker_services/releases/download/v0.9.1/docker_services \
            > /tmp/docker_services && \
            chmod +x /tmp/docker_services && \
            sudo mv /tmp/docker_services /usr/local/bin && \
            docker_services bootstrap

## Hooking into "cd"

This tool relies on being able to change environment variables when you change directories, so it needs to hook into `cd`. However, it's fairly common for tools to redefine `cd`, and it can only be overriden once.

So first check what your `cd` does:

    $ type cd

If it says "cd is a shell builtin", then add this to your profile:

    if [ -s "$HOME/.docker_services/shell" ]; then
      source $HOME/.docker_services/shell

      cd ()
      {
          if builtin cd "$@"; then
              __docker_services_set_environment_variables
              return 0;
          else
              return $?;
          fi
      }

      # Support the non-cd navigation in zsh
      [ $SHELL = "/usr/bin/zsh" ] && chpwd_functions+=("__docker_services_set_environment_variables")
    fi

If it says "cd is a function", then copy that existing function and add `__docker_services_set_environment_variables`.

## Usage

### Configure the project

You can find available service images on dockerhub, ex: <https://hub.docker.com/_/redis/>

    $ cd project
    $ printf "docker_services:\n  redis:\n    image: redis:2.8\n" > dev.yml

### Starting and stopping services

This will also pull down the docker image from dockerhub if it's not already installed.

    docker_service start
    docker_service stop
    
Example:

![](https://dl.dropboxusercontent.com/u/136929/docker_services_usage.png)

### How environment variables are handled

Environment variables are automatically set and cleared using a "cd" hook:

    $ cd project_already_using_docker_services

    $ export | grep PORT
    REDIS_PORT=1234

    $ cd ..

    $ export | grep PORT

### Custom environment variables

You can add custom environment variables (like $PGPORT) in [DockerServices.CustomEnvironment](/lib/docker_services/custom_environment.ex). This requires [rebuilding docker\_services from source](#development). Pull requests with custom envs are welcome. If you feel the env you add isn't useful to anyone else, then let's discuss other options (config files, etc).

Heroku compatibility:

As far as possible the [DockerServices.CustomEnvironment](/lib/docker_services/custom_environment.ex) variables will have the same names as used on heroku, e.g. `$REDIS_PROVIDER`. This simplifies app config.

## Where is data stored?

Data is stored outside of docker in `~/.docker_services/projects/project_identifier/data/service_name`. The path is mounted as a volume within the docker service when it's run.

## Why call the config file "dev.yml"?

It's the config format we've been using internally for various development config. Please post an issue if you have ideas around config. It might support several different ones later on. I would like to try and avoid "DockerServicesFile" though :)

# Development

This is an [Elixir](http://elixir-lang.org/) project. It being developed with Erlang 18+ and Elixir 1.1+.

If you're on OSX, just run "brew install erlang && brew install elixir" to install them.

    mix deps.get
    mix test

    # MIX_ENV=prod mix escript.build
    # scp docker_services test_server:/usr/local/bin && ssh test_server "docker_services bootstrap"

# Release

1) Build script:

    MIX_ENV=prod mix escript.build

2) Go to <https://github.com/joakimk/docker_services/releases> and make a release.

3) Update install instructions in [readme](https://github.com/joakimk/docker_services/edit/master/README.md).

# TODO

- [x] Implement start with a fake docker client
- [x] Implement stop with a fake docker client
- [x] Move ~/.docker\_services root path into config
- [x] Implement the real docker client and make it all work
- [x] Add support for custom ENVs for some services like postgres.
- [x] Handle exit status in Docker
- [x] Nicer behavior when you stop or start twice
- [x] Support more than one of the same service in a project?
- [x] Make it work with new images that hasn't been pulled down yet
  - [x] Display result from pulling new images right away, and tell the user it's happening
  - [x] Make sure it works the first time the command is run
- [x] Use in internal projects
  - [x] Add to chef recipes and make sure it works
  - [x] Try using it in a project
  - [x] See if we could use simpler updates than applying the chef recipes (wontfix for now, want it locked down to a known good version, might work on update-available-notifications instead)
- [ ] Ensure it works in zsh
  - [x] Try to reproduce the error myself (could not reproduce)
  - [ ] Wait for feedback from a zsh user at work
- [ ] Release 1.0? :)

Ideas for after 1.0:

- [x] "docker\_services backup postgres /tmp/postgres.tar.gz" to create a .tar.gz file of the service data
- [x] "docker\_services restore postgres /tmp/postgres.tar.gz" restore service data from a .tar.gz file
- [x] remove any existing file before restoring
- [ ] check if ensure works on a new machine, may have to add a mkdir\_p
- [ ] only stop the service that is being backed up or restored
- [ ] "docker\_services ps"
- [ ] Add CI

## License

Copyright (c) 2015 [Joakim Kolsjö](https://twitter.com/joakimk)

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
