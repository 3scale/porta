FROM quay.io/centos/centos:stream8 AS build
ENV DNF_INSTALL_OPTS="-y --allowerasing --setopt=skip_missing_names_on_install=False --setopt=install_weak_deps=false --nodocs"
RUN dnf install $DNF_INSTALL_OPTS podman-catatonit


FROM quay.io/centos/centos:stream8

ARG BUNDLER_ENV
ARG NPM_REPO
ARG GEMS_REPO
ENV RAILS_ENV=production \
    BUNDLER_ENV="${BUNDLER_ENV}" \
    BUNDLE_GEMFILE=Gemfile \
    BUNDLE_WITHOUT=development:test \
    DNF_INSTALL_OPTS="-y --allowerasing --setopt=skip_missing_names_on_install=False --setopt=install_weak_deps=false --nodocs" \
    TZ=:/etc/localtime \
    SAFETY_ASSURED=1 \
    NODE_OPTIONS="--max_old_space_size=4096" \
    NPM_REPO="${NPM_REPO}" \
    GEMS_REPO="${GEMS_REPO}"

WORKDIR /opt/system

RUN dnf config-manager --set-enabled powertools \
    && dnf install $DNF_INSTALL_OPTS epel-release \
    && dnf -y module enable ruby:2.6 nodejs:12 \
    && dnf install $DNF_INSTALL_OPTS \
              autoconf automake make cmake libtool gcc-c++ pkgconf redhat-rpm-config \
              openssl-devel zlib-devel glibc-devel \
              npm \
              ruby-devel rubygem-bigdecimal rubygem-io-console\
              ImageMagick \
              ImageMagick-devel \
              unixODBC-devel \
              mysql-devel \
              libpq-devel \
              git \
              file \
    && dnf -y clean all

# Install sphinx search
# TODO: sphinx (compile?) for all supported archs
ARG SPHINX_VERSION=3.4.1
RUN curl -sSL https://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-efbcc65-linux-amd64.tar.gz | tar xz -C /tmp \
    && cp /tmp/sphinx-${SPHINX_VERSION}/bin/* /usr/bin/ \
    && rm -rf /tmp/sphinx*

# We don't want to redo the bundle install step every time a file has changed:
# copying only the gemspec files and copying all the other files after the build
ADD lib/developer_portal/*.gemspec lib/developer_portal/
ADD vendor/active-docs/*.gemspec vendor/active-docs/
ADD Gemfile* ./
ADD Rakefile ./

RUN export ${BUNDLER_ENV} >/dev/null \
    && echo "gem: --no-document" > ~/.gemrc \
    && gem install bundler --version 2.2.25 \
    && bundle config set --local deployment 'true' \
    && bundle install --jobs $(grep -c processor /proc/cpuinfo) --retry=5

RUN chgrp root /opt/system/

ADD . ./
ADD config/docker/* ./config/
ADD package.json ./
ADD yarn.lock ./
ADD openshift/system/config/* ./config/

RUN export ${BUNDLER_ENV} >/dev/null \
    && bundle exec rake tmp:create \
    && mkdir -p public/assets db/sphinx \
    && chmod g+w -vfR log tmp public/assets db/sphinx \
    && umask 0002 \
    && cd /opt/system \
    && npm --unsafe-perm install -g yarn \
    && yarn install:safe --no-progress \
    && SECRET_KEY_BASE=rails/32947 bundle exec rake assets:precompile tmp:clear \
    && rm log/*.log \
    && chmod g+w /opt/system/config

# with RHEL 9.1 we can just install package podman-catatonit
COPY --from=build /usr/libexec/podman/catatonit /usr/libexec/podman/

USER 1001
ADD openshift/system/entrypoint.sh /opt/system/entrypoint.sh
ADD openshift/system/container-entrypoint /usr/bin/container-entrypoint
EXPOSE 3000 9306
ENTRYPOINT ["/usr/bin/container-entrypoint", "/opt/system/entrypoint.sh"]
CMD ["unicorn", "-c", "config/unicorn.rb", "-E", "${RAILS_ENV}", "config.ru"]

# vim: set ft=dockerfile:
