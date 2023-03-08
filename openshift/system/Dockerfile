FROM quay.io/centos7/ruby-26-centos7 AS porta-base

USER root

ENV RUBY_MAJOR_VERSION=2 \
    RUBY_MINOR_VERSION=6

ENV RUBY_VERSION="${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION}" \
    RUBY_SCL_NAME_VERSION="${RUBY_MAJOR_VERSION}${RUBY_MINOR_VERSION}"

ENV TZ=:/etc/localtime \
    BUNDLE_GEMFILE=Gemfile \
    BUNDLE_WITHOUT=development:test \
    VARNISH_SCL=rh-varnish5 \
    NODEJS_SCL=rh-nodejs12 \
    RUBY_SCL="rh-ruby${RUBY_SCL_NAME_VERSION}" \
    GIT_SCL=rh-git227

WORKDIR /opt/system

RUN yum-config-manager --save --setopt=cbs.centos.org_repos_sclo7-$RUBY_SCL-rh-candidate_x86_64_os_.skip_if_unavailable=true \
    && rpm -Uvh https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && yum -y update \
    && yum remove -y postgresql \
    && yum install -y epel-release \
    && yum -y install centos-release-scl-rh \
              ImageMagick \
              ImageMagick-devel \
              unixODBC-devel \
              mysql \
              llvm5.0-devel \
              postgresql13 postgresql13-devel postgresql13-libs \
              file \
              $NODEJS_SCL \
              $VARNISH_SCL-jemalloc \
              $GIT_SCL \
    && yum -y clean all \
    && scl enable $VARNISH_SCL -- printf '$LIBRARY_PATH' | cut -d: -f1 > /etc/ld.so.conf.d/jemalloc.conf \
    && ldconfig && ldconfig -p | grep jemalloc

# Install sphinx search
RUN if [ "`uname -m`" == "x86_64" ]; then \
      yum install -y https://sphinxsearch.com/files/sphinx-2.2.11-1.rhel7.x86_64.rpm ; \
    else \
      curl -sSL http://sphinxsearch.com/files/sphinx-2.2.11-release.tar.gz | tar xz -C /tmp \
      && cd /tmp/sphinx-2.2.11-release && ./configure && make install \
      && rm -rf /tmp/sphinx* ; \
    fi

# We don't want to redo the bundle install step every time a file has changed:
# copying only the gemspec files and copying all the other files after the build
ADD lib/developer_portal/*.gemspec lib/developer_portal/
ADD vendor/active-docs/*.gemspec vendor/active-docs/
ADD Gemfile* ./
ADD Rakefile ./

COPY openshift/system/contrib/scl_enable /opt/app-root/etc/

ENV BASH_ENV=/opt/app-root/etc/scl_enable \
    ENV=/opt/app-root/etc/scl_enable \
    PROMPT_COMMAND=". /opt/app-root/etc/scl_enable" \
    RAILS_ENV=production \
    SAFETY_ASSURED=1

RUN source /opt/app-root/etc/scl_enable \
    && gem install bundler --version 2.2.25 \
    && bundle config build.pg --with-pg-config=/usr/pgsql-13/bin/pg_config \
    && bundle install --deployment --jobs $(grep -c processor /proc/cpuinfo) --retry=5

RUN chgrp root /opt/system/

ADD . ./
ADD config/docker/* ./config/
ADD package.json ./
ADD yarn.lock ./
ADD openshift/system/config/* ./config/

RUN source /opt/app-root/etc/scl_enable \
    && bundle exec rake tmp:create \
    && mkdir -p public/assets db/sphinx \
    && chmod g+w -vfR log tmp public/assets db/sphinx \
    && umask 0002 \
    && cd /opt/system \
    && npm install -g yarn \
    && yarn install:safe --no-progress \
    && SECRET_KEY_BASE=rails/32947 bundle exec rake assets:precompile tmp:clear \
    && rm log/*.log \
    && chmod g+w /opt/system/config

ADD openshift/system/entrypoint.sh /opt/system/entrypoint.sh
USER 1001
EXPOSE 3000 9306
# TODO: dumb-init!
ENTRYPOINT ["/opt/system/entrypoint.sh"]
CMD ["unicorn", "-c", "config/unicorn.rb", "-E", "${RAILS_ENV}", "config.ru"]


FROM porta-base AS porta-sphinx-config
ENV THINKING_SPHINX_ADDRESS=0.0.0.0 \
    THINKING_SPHINX_PID_FILE=/var/run/sphinx/searchd.pid \
    THINKING_SPHINX_INDICES_LOCATION=/var/lib/sphinx \
    THINKING_SPHINX_CONFIGURATION_FILE=/opt/system/config/standalone.sphinx.conf \
    RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    DATABASE_URL='mysql2://root:@localhost/porta'
USER 0
RUN yum install -y mariadb-server \
    && setpriv --reuid 27 --regid 27 --clear-groups mysql_install_db \
    && (mysqld_safe &) \
    && cp -v config/docker/thinking_sphinx.yml config/ \
    && ./entrypoint.sh bundle exec rake db:create db:schema:load openshift:thinking_sphinx:configure \
    && grep -q "rt_field = account_id" "$THINKING_SPHINX_CONFIGURATION_FILE" \
    && kill $(</var/run/mariadb/mariadb.pid)


FROM porta-base AS porta-prod
COPY --from=porta-sphinx-config /opt/system/config/standalone.sphinx.conf /opt/system/config/
