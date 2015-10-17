# NOTE: Readme driven development below, this means this tool does not necessarily do what it says below yet.

**Status**: just starting out

## What is this?

A tool to run multiple versions of services like redis or postgres within the same computer without having port collisions using docker.

## Motivation

We've been using tools like this at <https://dev.auctionet.com> with great success for more than a year. It has enabled us to develop many small and big projects in a single vagrant VM. Even if vagrant is great for isolating projects, sometimes it's a bit heavyweight.

## Installation

    curl something | bash

## Usage

### Setup and start services

    $ cd project
    $ echo "docker_services:\n  redis:\n  docker_image: redis:2.8" > dev.yml
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

### What if something already has the "cd" shell function?

    type cd
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

Copy that code into your bash shell, and below `__rvm_cd_functions_set`, add `docker_services env` and you will be able to have both rvm and docker\_services :).

# Development

todo
