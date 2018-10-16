#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# lets make everything readable by everyone
umask 0000

if [ "x$MULTIJOB_KIND" == "x" ]; then

    MULTIJOB_KIND="integrate"
fi

# We do want it possible for multiple rake tasks to be passed as argument here.
# shellcheck disable=SC2086
exec env bundle exec rake ${MULTIJOB_KIND} --trace
