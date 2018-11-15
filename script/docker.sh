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

echo
echo "======= Bundler ======="
echo
bundle check --path=vendor/bundle --gemfile="Gemfile" || time bash -c "bundle install --deployment --retry=5 --gemfile=Gemfile"
bundle config
echo

echo
echo "======= NPM ======="
echo
yarn --version
time bash -c "CXX=g++-4.8 ${PROXY_ENV} yarn install"
echo

echo "======= JSPM ======="
echo
jspm -v
jspm config registries.github.auth ${GITHUB_REPOSITORY_TOKEN}
time bash -c "${PROXY_ENV} jspm dl-loader"
time bash -x -c "export ${PROXY_ENV}; jspm install --lock|| jspm install --force"
echo

echo "======= APIcast ======="

pushd vendor/docker-gateway
time bash -c "${PROXY_ENV} make dependencies"
popd
