#!/usr/bin/env bash

set +o pipefail

# Execute this script by a user with read right ability to /opt/oracle and /opt/system/vendor/oracle

declare oracle_otn=https://download.oracle.com/otn_software/linux/instantclient/19600
declare oracle_version=linux.x64-19.6.0.0.0dbru
declare -a packages=(instantclient-basiclite instantclient-sdk instantclient-odbc)

for package in "${packages[@]}"; do
  zip=${package}-${oracle_version}.zip
  wget "${oracle_otn}/${zip}" -O "vendor/oracle/${zip}"
  # using sudo due to `/opt/oracle/` i
  # set in: https://github.com/3scale/system-builder/blob/1bc3cec26bff04e0603e1a4908594b70a114dfe8/Dockerfile#L16-L17
  unzip "vendor/oracle/${zip}" -d /opt/oracle
  rm -rf "vendor/oracle/${zip}"
done

# hack for system-builder ENV
rm -rf /opt/system/vendor/oracle
ln -sf /opt/oracle/instantclient_19_6/libsqora.so.19.1 /opt/oracle/instantclient_19_6/libsqora.so
ln -sf /opt/oracle/instantclient_19_6 /opt/oracle/instantclient
cp config/oracle/*.ini /etc/
