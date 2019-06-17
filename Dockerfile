FROM quay.io/3scale/system-builder:ruby24

ARG SPHINX_VERSION=2.2.11
ARG BUNDLER_VERSION=1.17.3
ARG DB=mysql
ARG MASTER_PASSWORD=p
ARG USER_PASSWORD=p

ENV BUNDLE_FROZEN="true" \
    BUNDLE_PATH="vendor/bundle" \
    DISABLE_SPRING="true" \
    ORACLE_SYSTEM_PASSWORD="threescalepass" \
    NLS_LANG="AMERICAN_AMERICA.UTF8" \
    TZ="UTC" \
    MASTER_PASSWORD="${MASTER_PASSWORD}" \
    USER_PASSWORD="${USER_PASSWORD}" \
    LC_ALL="en_US.UTF-8"


ENV PATH="./node_modules/.bin:$PATH:/usr/local/nginx/sbin/" \
    SKIP_ASSETS="1" \
    DNSMASQ="#" \
    RAILS_ENV=test \
    CODECLIMATE_REPO_TOKEN=ba3a56916aa6040ae614ffa6b3d87f6ea07d3c0c512e8099cec4e68b27b676fc \
    GITHUB_REPOSITORY_TOKEN=b2N0b2JvdDo0YWUwYjYzOTgzYWE5YzYyZTIyOWYxZWNmZGZiNDY2YjI1YzcyZWEy \
    BUNDLE_FROZEN=1 \
    TZ=:/etc/localtime \
    LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2/ \
    ORACLE_HOME=/opt/oracle/instantclient_12_2/ \
    DB=$DB \
    SAFETY_ASSURED=1

WORKDIR /opt/system/

VOLUME [ "/opt/system/tmp/cache/", \
         "/opt/system/vendor/bundle", \
         "/opt/system/node_modules", \
         "/opt/system/public/assets", \
         "/opt/system/public/packs-test", \
         "/home/ruby/.luarocks" ]

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

USER 1001
RUN bash -c "bundle install && npm install"
