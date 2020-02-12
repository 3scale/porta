FROM quay.io/3scale/system-builder:ruby25

ARG SPHINX_VERSION=2.2.11
ARG BUNDLER_VERSION=1.17.3
ARG DB=mysql
ARG MASTER_PASSWORD=p
ARG USER_PASSWORD=p

ENV DISABLE_SPRING="true" \
    ORACLE_SYSTEM_PASSWORD="threescalepass" \
    NLS_LANG="AMERICAN_AMERICA.UTF8" \
    TZ="UTC" \
    MASTER_PASSWORD="${MASTER_PASSWORD}" \
    USER_PASSWORD="${USER_PASSWORD}" \
    LC_ALL="en_US.UTF-8" \
    PATH="./node_modules/.bin:/opt/rh/rh-nodejs10/root/usr/bin:$PATH" \
    SKIP_ASSETS="1" \
    DNSMASQ="#" \
    CODECLIMATE_REPO_TOKEN=ba3a56916aa6040ae614ffa6b3d87f6ea07d3c0c512e8099cec4e68b27b676fc \
    GITHUB_REPOSITORY_TOKEN=b2N0b2JvdDo0YWUwYjYzOTgzYWE5YzYyZTIyOWYxZWNmZGZiNDY2YjI1YzcyZWEy \
    BUNDLE_FROZEN=1 \
    BUNDLE_JOBS=5 \
    TZ=:/etc/localtime \
    LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2/ \
    ORACLE_HOME=/opt/oracle/instantclient_12_2/ \
    DB=$DB \
    SAFETY_ASSURED=1 \
    UNICORN_WORKERS=2

WORKDIR /opt/system/

ADD . ./
ADD config/examples/*.yml config/
# Needed for Sphinx ODBC
ADD config/oracle/odbc*.ini /etc/

# Oracle special, this needs Oracle to be present in vendor/oracle
ADD vendor/oracle/* /opt/oracle/
RUN if [ "${DB}" = "oracle" ]; then unzip /opt/oracle/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /opt/oracle/ \
 && unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle/ \
 && unzip /opt/oracle/instantclient-odbc-linux.x64-12.2.0.1.0-2.zip -d /opt/oracle/ \
 && (cd /opt/oracle/instantclient_12_2/ && ln -s libclntsh.so.12.1 libclntsh.so) \
 && rm -rf /opt/system/vendor/oracle \
 && rm -rf /opt/oracle/*.zip; fi

USER root

# Needed to disable webpack compiling
RUN sed -i 's/compile: true/compile: false/' config/webpacker.yml

RUN bash -c "bundle install && bundle exec rake tmp:create"
RUN bash -c "npm install -g yarn && yarn install:safe && rake assets:precompile"
