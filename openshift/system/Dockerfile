FROM centos/ruby-23-centos7

USER root

ARG BUNDLER_ENV
ENV BUNDLER_ENV="${BUNDLER_ENV}" \
    TZ=:/etc/localtime \
    BUNDLE_GEMFILE=gemfiles/prod/Gemfile \
    BUNDLE_WITHOUT=development:test

WORKDIR /opt/system

ARG SPHINX_VERSION=2.2.11-1

ADD openshift/system/sphinx-${SPHINX_VERSION}.rhel7.x86_64.rpm /tmp/sphinxsearch.rpm

RUN yum -y update \
    && yum -y install ImageMagick \
                      ImageMagick-devel \
                      unixODBC-devel \
                      mysql \
                      file \
    && rpm -i /tmp/sphinxsearch.rpm \
    && rm /tmp/*.rpm \
    && yum install -y epel-release \
    && yum -y clean all

# We don't want to redo the bundle install step every time a file has changed:
# copying only the gemspec files and copying all the other files after the build
ADD lib/developer_portal/*.gemspec lib/developer_portal/
ADD vendor/active-docs/*.gemspec vendor/active-docs/
ADD Gemfile.base ./
ADD gemfiles ./gemfiles
ADD Rakefile ./

COPY openshift/system/contrib/scl_enable /opt/system/etc/

ENV BASH_ENV=/opt/system/etc/scl_enable \
    ENV=/opt/system/etc/scl_enable \
    PROMPT_COMMAND=". /opt/system/etc/scl_enable" \
    RAILS_ENV=production

RUN export ${BUNDLER_ENV} >/dev/null \
    && source /opt/system/etc/scl_enable \
    && gem install bundler --version 1.17.3 \
    && bundle install --deployment --jobs $(grep -c processor /proc/cpuinfo) --retry=5

RUN chgrp root /opt/system/

ADD . ./
ADD config/docker/* ./config/
ADD package*.json ./

RUN export ${BUNDLER_ENV} >/dev/null \
    && source /opt/system/etc/scl_enable \
    && bundle exec rake tmp:create \
    && mkdir -p public/assets db/sphinx \
    && chmod g+w -vfR log tmp public/assets db/sphinx \
    && umask 0002 \
    && cd /opt/system \
    && rm -rf /opt/system/node_modules \
    && npm cache clean --force \
    && npm install --no-progress \
    && bundle exec rake assets:precompile tmp:clear \
    && rm log/*.log \
    && chmod g+w /opt/system/config

USER 1001
ADD openshift/system/entrypoint.sh /opt/system/entrypoint.sh
EXPOSE 3000 9306
# TODO: dumb-init!
ENTRYPOINT ["/opt/system/entrypoint.sh"]
CMD ["unicorn", "-c", "config/unicorn.rb", "-E", "${RAILS_ENV}", "config.ru"]

# vim: set ft=dockerfile:
