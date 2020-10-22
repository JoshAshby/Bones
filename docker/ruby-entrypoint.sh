#!/bin/bash

set -euo pipefail

bundle exec rake db:migrate

# if a command was passed to this script, run it in the environment
if [[ $# -gt 0 ]]; then
  echo "Running command $@"
  exec bash -c "$@"
fi

exec bundle exec thin start
