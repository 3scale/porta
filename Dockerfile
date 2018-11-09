FROM quay.io/3scale/docker:ci-2.3.7-1

ARG SPHINX_VERSION=2.2.11
ARG BUNDLER_VERSION=1.12.5
ARG DB=mysql

# Don't use ubuntu mirrors. Rather slow download, than failing build.
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse\n\
deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" > /etc/apt/sources.list

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 60C317803A41BA51845E371A1E9377A2BA9EF27F \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D101F7899D41F3C3 \
 && apt-get update -y && apt-get install -y apt-transport-https \
 && echo 'deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu xenial main' > /etc/apt/sources.list.d/toolchain.list \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
 && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get install -y -f g++-4.8 nodejs squid3 yarn=1.2.1-1 libaio1 \
 && gem install bundler --version ${BUNDLER_VERSION} --no-document \
 && sed --in-place "s/databases 16/databases 32/" /etc/redis/redis.conf \
 && mkdir /etc/squid3 \
 && echo 'dns_nameservers 8.8.8.8 8.8.4.4' >> /etc/squid3/squid.conf \
 && cd /tmp && curl -o sphinxsearch.deb -J -L -O https://github.com/sphinxsearch/sphinx/releases/download/${SPHINX_VERSION}-release/sphinxsearch_${SPHINX_VERSION}-release-1.xenial_amd64.deb \
 && curl -o unixODBC.deb -J -L -O https://github.com/3scale/unixODBC/releases/download/2.3.6-ubuntu-16.04/unixODBC_2.3.6_amd64.deb \
 && apt-get -y install libodbc1 \
 && dpkg --install sphinxsearch.deb \
 && dpkg --install unixODBC.deb \
 && apt-get autoremove -y \
 && rm -f sphinxsearch_${SPHINX_VERSION}.deb unixODBC.deb

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
    DB=$DB

WORKDIR /opt/system/

VOLUME [ "/opt/system/tmp/cache/", \
         "/opt/system/vendor/bundle", \
         "/opt/system/node_modules", \
         "/opt/system/assets/jspm_packages", \
         "/opt/system/public/assets", \
         "/opt/system/public/packs-test", \
         "/root/.jspm", "/home/ruby/.luarocks" ]

ADD . ./
ADD config/examples/*.yml config/
# Needed for Sphinx ODBC
ADD config/oracle/odbc*.ini /etc/

ENTRYPOINT ["xvfb-run", "--server-args", "-screen 0 1280x1024x24"]
CMD ["script/jenkins.sh"]

# Oracle special, this needs Oracle to be present in vendor/oracle
ADD vendor/oracle/* /opt/oracle/
RUN if [ "${DB}" = "oracle" ]; then unzip /opt/oracle/instantclient-basiclite-linux.x64-12.2.0.1.0.zip -d /opt/oracle/ \
 && unzip /opt/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /opt/oracle/ \
 && unzip /opt/oracle/instantclient-odbc-linux.x64-12.2.0.1.0-2.zip -d /opt/oracle/ \
 && (cd /opt/oracle/instantclient_12_2/ && ln -s libclntsh.so.12.1 libclntsh.so) \
 && rm -rf /opt/system/vendor/oracle \
 && rm -rf /opt/oracle/*.zip; fi
