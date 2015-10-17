# NOTE: Readme driven development below, this means this tool does not necessarily do what it says below yet.

**Status**: just starting out

## What is this?

A tool to run multiple versions of services like redis or postgres on the same computer without having port collisions using docker.

## Motivation

We've been using tools like this at [auctionet.com](http://dev.auctionet.com) with great success for more than a year. It has enabled us to develop many small and big projects in a single vagrant VM. Even if vagrant is great for isolating projects, sometimes it's a bit heavyweight.

I've tried to release this as part of a [bigger project](https://github.com/joakimk/devbox-tools) before, but have realised that it has value as a stand alone tool.

## Installation

First install the tool

    curl something | bash

Add the shell function `docker_services` to your shell profile.

    # Example
    echo 'source /usr/local/lib/docker\_services/shell' >> .profile

### Adding the "cd" shell hook

This tool does not automatically override "cd", but will be much easier to use if you do.

#### When there already is a hook:

    $ type cd

    cd is a function
    cd ()
    {
        if builtin cd "$@"; then
            [[ -n "${rvm_current_rvmrc:-}" && "$*" == "." ]] && rvm_current_rvmrc="" || true;
            __rvm_cd_functions_set;
            return 0;
        else
            return $?;
        fi
    }

Copy that code into your shell profile, and below `__rvm_cd_functions_set`, add `docker_services set_environment_variables` and you will be able to have both rvm and docker\_services :).

#### If there is no hook:

    $ type
    cd is a shell builtin

Add a hook to your profile below the line that loads `docker_services`:

    cd ()
    {
        if builtin cd "$@"; then
            docker_services set_environment_variables
            return 0;
        else
            return $?;
        fi
    }

## Usage

### Setup and start services

    $ cd project
    $ printf "docker_services:\n  redis:\n    image: redis:2.8\n" > dev.yml
    $ docker_services start
      Starting service: redis:2.8... done
    $ export | grep PORT
    REDIS_PORT=1234
    $ redis-cli -p $REDIS_PORT
    127.0.0.1:1234>

### Stopping services

    $ docker_services stop
    $ export | grep PORT

### How environment variables are handled

Environment variables are automatically set and cleared using a "cd" hook, like rvm.

    $ cd project_already_using_docker_services
    $ export | grep PORT
    REDIS_PORT=1234
    $ cd ..
    $ export | grep PORT

# Development

todo
