#!/bin/bash

export MIX_ENV="test"
export PATH="$HOME/dependencies/erlang/bin:$HOME/dependencies/elixir/bin:$PATH"

set -e

mix test

MIX_ENV=prod mix escript.build
mv docker_services $CIRCLE_ARTIFACTS/
