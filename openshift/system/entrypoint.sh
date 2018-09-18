#!/bin/bash

EXTRA_CONFIGS_DIR=${EXTRA_CONFIGS_DIR:-/opt/system-extra-configs}
BASE_CONFIGS_DIR=${BASE_CONFIGS:-/opt/system/config}
if [ -d "${EXTRA_CONFIGS_DIR}" ]; then
    for configfile in ${EXTRA_CONFIGS_DIR}/*.yml; do
        baseconfigfile=$(basename "$configfile")
        ln -sf "${configfile}" "${BASE_CONFIGS_DIR}/${baseconfigfile}"
    done
fi

# Exporting all bundler environment
export ${BUNDLER_ENV}

exec bundle exec "$@"
