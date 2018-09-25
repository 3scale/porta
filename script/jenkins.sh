#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

"${SCRIPT_DIR}/docker.sh"

# lets make everything readable by everyone
umask 0000

cp config/examples/*.yml config/
# Needed for Sphinx ODBC
cp config/oracle/odbc*.ini /etc/

echo "======= Assets Precompile ======="
set -x

time bundle exec rake assets:precompile RAILS_GROUPS=assets RAILS_ENV=production WEBPACKER_PRECOMPILE=false
time bundle exec rake assets:precompile RAILS_GROUPS=assets RAILS_ENV=test WEBPACKER_PRECOMPILE=false

boot_database()
{
    bin/rake boot:database TEST_ENV_NUMBER=8
}

until boot_database; do
  sleep 1
done

if [ "x$DB" = "xoracle" ]; then
  echo "Waiting for 60 seconds for the DB to be ready"
  sleep 60
fi

if [ "x$PROXY_ENABLED" == "x1" ]; then
  source "${SCRIPT_DIR}/proxy_env.sh"
fi

if [ "x$MULTIJOB_KIND" == "x" ]; then

    MULTIJOB_KIND="integrate"
fi

# We do want it possible for multiple rake tasks to be passed as argument here.
# shellcheck disable=SC2086
exec env ${PROXY_ENV} bundle exec rake ${MULTIJOB_KIND} --trace
