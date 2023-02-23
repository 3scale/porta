#!/bin/bash

set -e

EXTRA_CONFIGS_DIR=${EXTRA_CONFIGS_DIR:-/opt/system-extra-configs}
BASE_CONFIGS_DIR=${BASE_CONFIGS:-/opt/system/config}

if [ -d "${EXTRA_CONFIGS_DIR}" ]; then
    for configfile in ${EXTRA_CONFIGS_DIR}/*.yml; do
        baseconfigfile=$(basename "$configfile")

        case $baseconfigfile in
            rolling_updates.yml)
                ln -sf "${configfile}" "${BASE_CONFIGS_DIR}/extra-${baseconfigfile}"
                ;;
            *)
                ln -sf "${configfile}" "${BASE_CONFIGS_DIR}/${baseconfigfile}"
                ;;
        esac
    done
fi

if ldconfig -p | grep jemalloc; then
  LD_PRELOAD="$LD_PRELOAD":$(ldconfig -p | grep jemalloc | head -1 | awk '{ print $1 }')
  export LD_PRELOAD
elif ldconfig -p | grep libautohbw; then
  # AUTO_HBW_SIZE is just a big number to avoit it ever reached
  # MEMKIND_HEAP_MANAGER=JEMALLOC is the default anyway but goot for reader
  # MEMKIND_HBW_NODES=0 just to prevent warning log
  HBWLIB=$(ldconfig -p | grep libautohbw | head -1 | awk '{ print $1 }')
  export LD_PRELOAD="$LD_PRELOAD":$HBWLIB AUTO_HBW_SIZE=10T AUTO_HBW_LOG=-2 MEMKIND_HBW_NODES=0 MEMKIND_HEAP_MANAGER=JEMALLOC
fi

exec bundle exec "$@"
