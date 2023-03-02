#!/usr/bin/env bash

set +o pipefail

# Execute this script by a user with read right ability to /opt/oracle and /opt/system/vendor/oracle
declare oracle_otn=https://download.oracle.com/otn_software/linux/instantclient/1918000
declare oracle_version=linux.x64-19.18.0.0.0dbru
declare -a packages=(instantclient-sdk instantclient-odbc)

function install_pkg {
  local package="$1"
  local zip="${package}-${oracle_version}.zip"
  local file="vendor/oracle/${zip}"

  if [ -f "${file}" ]; then
    echo "[OK] ${file} already present"
  else
    echo "[INFO] Downloading ${zip} from Oracle servers"
    wget "${oracle_otn}/${zip}" -O "${file}"
  fi

  # using sudo due to `/opt/oracle/` i
  # set in: https://github.com/3scale/system-builder/blob/1bc3cec26bff04e0603e1a4908594b70a114dfe8/Dockerfile#L16-L17
  unzip -o "${file}" -d /opt/oracle
  rm -rf "${file}"
}


for package in "${packages[@]}"; do
  install_pkg "$package"
done

# Particular case for instantclient-basiclite and instantclient-basic.
# No need to install both, if one is found use it otherwise use instantclient-basic
basiclite="vendor/oracle/instantclient-basiclite-${oracle_version}.zip"

if [ -f "${basiclite}" ]; then
  install_pkg "instantclient-basiclite"
else
  install_pkg "instantclient-basic"
fi

# hack for system-builder ENV
rm -rf /opt/system/vendor/oracle
ln -sf /opt/oracle/instantclient_19_18/libsqora.so.19.1 /opt/oracle/instantclient_19_18/libsqora.so
ln -sf /opt/oracle/instantclient_19_18 /opt/oracle/instantclient
cp config/oracle/*.ini /etc/
