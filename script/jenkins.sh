#!/usr/bin/env bash
set -e

SCRIPT_DIR=$(dirname "$(readlink -f $0)")

${SCRIPT_DIR}/docker.sh

# lets make everything readable by everyone
umask 0000

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

if [ "x$PROXY_ENABLED" == "x1" ]; then
  source "${SCRIPT_DIR}/proxy_env.sh"
fi
exec env $PROXY_ENV bundle exec rake integrate --trace
