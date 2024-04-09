FROM quay.io/centos/centos:stream8 as builder
WORKDIR /opt/system
ENV RUBY_MAJOR_VERSION=2 \
    RUBY_MINOR_VERSION=7 \
    RAILS_ENV=production \
    NODE_ENV=production
ENV RUBY_VERSION="${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION}"
ADD . ./
ADD openshift/system/config/* ./config/
RUN dnf -y --setopt=module_stream_switch=True module enable ruby:${RUBY_VERSION} nodejs:16 mysql:8.0 \
    && dnf install -y --setopt=skip_missing_names_on_install=False,tsflags=nodocs shared-mime-info make automake gcc gcc-c++ redhat-rpm-config postgresql rubygem-irb rubygem-rdoc ruby-devel nodejs libpq-devel mysql-devel gd-devel libxml2-devel libxslt-devel git 'dnf-command(download)' podman-catatonit \
    && BUNDLER_VERSION=$(awk '/BUNDLED WITH/ { getline; print $1 }' Gemfile.lock) \
    && gem install --no-document bundler:$BUNDLER_VERSION \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle config set --local without development:test:licenses \
    && bundle config set --local deployment true \
    && bundle install --jobs $(grep -c processor /proc/cpuinfo) --retry=5 \
    && npm install -g yarn \
    && yarn install:safe --no-progress \
    # TODO: update to SECRET_KEY_BASE_DUMMY=1 when we upgrade to Rails 7.0
    && SECRET_KEY_BASE=rails/32947 bundle exec rake assets:precompile tmp:clear \
    && rm -rf node_modules /usr/local/share/gems/cache /usr/local/share/gems/doc

# can just install memkind once it is fixed, see
# https://issues.redhat.com/browse/RHEL-14497
RUN cd /tmp \
    && dnf download --source memkind \
    && rpm2cpio memkind-*.src.rpm | cpio -idmv "memkind-*.tar.gz" \
    && tar xvfz memkind-*.tar.gz \
    && cd memkind-*/jemalloc/ \
    && ./autogen.sh && ./configure --libdir=/usr/local/lib64/ && make


FROM quay.io/centos/centos:stream8 AS base

USER root

ENV RUBY_MAJOR_VERSION=2 \
    RUBY_MINOR_VERSION=7 \
    RAILS_ENV=production \
    SAFETY_ASSURED=1 \
    TZ=:/etc/localtime \
    HOME=/opt/system \
    prometheus_multiproc_dir=/opt/system/tmp/prometheus-client-mmap-dir

ENV RUBY_VERSION="${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION}"

WORKDIR $HOME

RUN dnf -y module enable ruby:${RUBY_VERSION} nodejs:16 mysql:8.0 \
    && dnf install -y --setopt=skip_missing_names_on_install=False,tsflags=nodocs shared-mime-info postgresql rubygem-irb rubygem-rdoc ruby libpq mysql mysql-libs gd git liberation-sans-fonts file libxml2 libxslt \
    && dnf -y clean all

COPY --from=builder /opt/system/ .
COPY --from=builder /tmp/memkind-*/jemalloc/lib/libjemalloc.so* /usr/local/lib64
COPY --from=builder /usr/local/share/gems /usr/local/share/
COPY --from=builder /usr/local/bin/bundle* /usr/local/bin
# in RHEL 8 podman-catatonit pulls in too many useless deps so we don't install the RPM directly, on RHEL 9 simply use package `catatonit`
COPY --from=builder /usr/libexec/catatonit/catatonit /usr/libexec/catatonit/catatonit

RUN echo /usr/local/lib64 > /etc/ld.so.conf.d/jemalloc.conf \
    && ldconfig && ldconfig -p | grep jemalloc

RUN bundle config set --local without development:test:licenses:assets \
    && bundle exec rake tmp:create \
    && umask 0002 \
    && mkdir -p db/sphinx tmp/prometheus-client-mmap-dir \
    && chmod g+w -vfR log tmp public/assets db/sphinx \
    && rm -f log/*.log \
    && chmod g+w /opt/system /opt/system/config

# Bundler runs git commands on git dependencies
# https://bundler.io/guides/git.html#local-git-repos
# git will check if the current user is the owner of the git repository folder
# This was included in git v2.35.2 or newer.
# https://github.com/git/git/commit/8959555cee7ec045958f9b6dd62e541affb7e7d9
# Openshift changes the effective UID, so this git check needs to be bypassed.
RUN git config --global --add safe.directory '*'

# container-entrypoint is expected by the operator so keeping it for compatibility
RUN ln -s openshift/system/entrypoint.sh . \
    && ln -s /opt/system/openshift/system/contrib/container-entrypoint /usr/local/bin/

RUN rm -rf vendor/oracle/ test/ spec/ features/ lib/proxy \
    && cp config/oracle/*.ini /etc/

USER 1001
EXPOSE 3000 9306
ENTRYPOINT ["/usr/libexec/catatonit/catatonit", "--", "/opt/system/entrypoint.sh"]
CMD ["unicorn", "-c", "config/unicorn.rb", "-E", "${RAILS_ENV}", "config.ru"]


FROM base AS sphinx-config
ENV THINKING_SPHINX_ADDRESS=0.0.0.0 \
    THINKING_SPHINX_PID_FILE=/var/run/sphinx/searchd.pid \
    THINKING_SPHINX_INDICES_LOCATION=/var/lib/searchd \
    THINKING_SPHINX_CONFIGURATION_FILE=/opt/system/config/standalone.sphinx.conf \
    THINKING_SPHINX_QUERY_LOG=/dev/stdout \
    THINKING_SPHINX_LOG=/dev/stdout \
    RAILS_ENV=production \
    # TODO: update to SECRET_KEY_BASE_DUMMY=1 when we upgrade to Rails 7.0
    SECRET_KEY_BASE=dummy \
    DATABASE_URL='mysql2://root:@localhost/porta'
USER 0
RUN dnf install -y mysql-server mysql-test \
    && setcap -r /usr/libexec/mysqld \
    && setpriv --reuid 27 --regid 27 --clear-groups mysqld --initialize-insecure \
    && (mysqld_safe &) \
    && bundle exec rake db:create db:schema:load openshift:thinking_sphinx:configure \
    && grep -q "rt_field = account_id" "$THINKING_SPHINX_CONFIGURATION_FILE" \
    && kill $(</run/mysqld/mysqld.pid)

FROM base AS porta-prod
COPY --from=sphinx-config /opt/system/config/standalone.sphinx.conf /opt/system/config/
