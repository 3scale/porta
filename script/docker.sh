#!/usr/bin/env bash

set -e

git config --global url.https://github.com/.insteadOf git://github.com/

SCRIPT_DIR=$(dirname "$(readlink -f $0)")
source "${SCRIPT_DIR}/proxy_env.sh"

if test "x${DOCKER_ENV}" != "xbash"; then
  . ${SCRIPT_DIR}/lib/docker

  docker_launch_servers
fi

echo
echo "======= Docker environment ======="
echo
env
echo





