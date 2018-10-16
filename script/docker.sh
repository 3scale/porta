#!/usr/bin/env bash

set -e

git config --global url.https://github.com/.insteadOf git://github.com/

SCRIPT_DIR=$(dirname "$(readlink -f $0)")

if test "x${DOCKER_ENV}" != "xbash"; then
  . ${SCRIPT_DIR}/lib/docker

  docker_launch_servers
fi

echo
echo "======= Docker environment ======="
echo
env
echo

echo
echo "======= Seeding Config files ======="
echo
cp config/examples/*.yml config/
# Needed for Sphinx ODBC
cp config/oracle/odbc*.ini /etc/

