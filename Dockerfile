FROM quay.io/3scale/system-builder:ruby26-nodejs12

ARG CUSTOM_DB=mysql

ENV DISABLE_SPRING="true" \
    ORACLE_SYSTEM_PASSWORD="threescalepass" \
    NLS_LANG="AMERICAN_AMERICA.UTF8" \
    TZ="UTC" \
    MASTER_PASSWORD="p" \
    USER_PASSWORD="p" \
    LC_ALL="en_US.UTF-8" \
    PATH="./node_modules/.bin:/opt/rh/rh-nodejs12/root/usr/bin:$PATH" \
    DNSMASQ="#" \
    BUNDLE_FROZEN=1 \
    BUNDLE_JOBS=5 \
    DB=${CUSTOM_DB} \
    SAFETY_ASSURED=1

WORKDIR /opt/system/

ADD . ./
ADD config/examples/*.yml config/
# Needed for Sphinx ODBC
ADD config/oracle/odbc*.ini /etc/

USER root
RUN if [ "X${DB}" = "Xoracle" ]; then ./script/oracle/install-instantclient-packages.sh; fi

# Needed to disable webpack compiling
RUN sed -i 's/compile: true/compile: false/' config/webpacker.yml

RUN bash -c "bundle install && bundle exec rake tmp:create"
RUN bash -c "npm install -g yarn && yarn install:safe && rake assets:precompile"
