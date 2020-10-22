#!/bin/bash

set -euo pipefail

# if a command was passed to this script, run it in the environment
if [[ $# -gt 0 ]]; then
  echo "Running command $@"
  exec bash -c "$@"
fi

exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
