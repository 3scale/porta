FROM registry.redhat.io/ubi7/ruby-25:2.5-91

ENV BASH_ENV=/opt/app-root/etc/scl_enable \
   ENV=/opt/app-root/etc/scl_enable \
   PROMPT_COMMAND=". /opt/app-root/etc/scl_enable" \
   RAILS_ENV=production \
   SAFETY_ASSURED=1 \
   BUNDLE_WITHOUT=development:test \
   TZ=:/etc/localtime \
   BUNDLE_GEMFILE=Gemfile \
   NODE_OPTIONS="--max_old_space_size=4096" \
   NODEJS_SCL=rh-nodejs10

EXPOSE 3000 9306

USER root

WORKDIR /opt/system

# required by node-pre-gyp to build node-canvas from source
# https://github.com/Automattic/node-canvas/wiki/Installation:-Fedora-and-other-RPM-based-distributions
RUN PKGS='ImageMagick unixODBC-devel libaio file gcc-c++ libjpeg-turbo-devel rh-nodejs10' \
    && yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager yum-utils \
    && yum-config-manager --enable rhel-7-server-optional-rpms \
    && yum-config-manager --enable rhel-server-rhscl-7-rpms \
    && yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager $PKGS \
    && rpm --verify --nogroup --nouser $PKGS \
    && yum -y clean all

# ImageMagick-devel
RUN yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/bzip2-devel-1.0.6-13.el7.i686.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXext-devel-1.3.3-3.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libtiff-devel-4.0.3-35.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/jasper-devel-1.900.1-33.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libICE-devel-1.0.9-9.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libSM-devel-1.2.2-2.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXt-devel-1.1.5-3.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libgs-devel-9.25-5.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/updates/x86_64/Packages/ImageMagick-devel-6.9.10.68-5.el7_9.x86_64.rpm

# mariadb (mysql)
RUN yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/mariadb-5.5.68-1.el7.x86_64.rpm

# postgresql10
RUN yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager \
    https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/postgresql10-10.17-1PGDG.rhel7.x86_64.rpm \
    https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/postgresql10-devel-10.17-1PGDG.rhel7.x86_64.rpm \
    https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/postgresql10-libs-10.17-1PGDG.rhel7.x86_64.rpm

# sphinx
ADD openshift/system/sphinx-2.2.11-1.rhel7.x86_64.rpm /tmp/sphinxsearch.rpm
RUN rpm -i /tmp/sphinxsearch.rpm \
    && rm -rf /tmp/sphinxsearch.rpm

# cairo-devel
RUN yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/gl-manpages-1.1-7.20130122.el7.noarch.rpm \
    http://mirror.centos.org/centos/7/updates/x86_64/Packages/glib2-devel-2.56.1-9.el7_9.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libdrm-devel-2.4.97-2.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libglvnd-core-devel-1.0.1-0.8.git5baa1e5.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libglvnd-devel-1.0.1-0.8.git5baa1e5.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libglvnd-gles-1.0.1-0.8.git5baa1e5.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libglvnd-opengl-1.0.1-0.8.git5baa1e5.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXdamage-devel-1.1.4-4.1.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXfixes-devel-5.0.3-1.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXrender-devel-0.9.10-1.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXxf86vm-devel-1.1.4-1.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/updates/x86_64/Packages/mesa-khr-devel-18.3.4-12.el7_9.x86_64.rpm \
    http://mirror.centos.org/centos/7/updates/x86_64/Packages/mesa-libEGL-devel-18.3.4-12.el7_9.x86_64.rpm \
    http://mirror.centos.org/centos/7/updates/x86_64/Packages/mesa-libGL-devel-18.3.4-12.el7_9.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/pixman-devel-0.34.0-1.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/cairo-devel-1.15.12-4.el7.x86_64.rpm

# pango-devel
RUN yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/fribidi-devel-1.0.2-1.el7_7.1.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/graphite2-devel-1.3.10-1.el7_3.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/harfbuzz-devel-1.7.5-2.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/harfbuzz-icu-1.7.5-2.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/libXft-devel-2.3.2-2.el7.x86_64.rpm \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/pango-devel-1.42.4-4.el7_7.x86_64.rpm

# giflib-devel
RUN yum -y install --setopt=tsflags=nodocs --disableplugin=subscription-manager \
    http://mirror.centos.org/centos/7/os/x86_64/Packages/giflib-devel-4.1.6-9.el7.x86_64.rpm

# Copy only the gemspec files so we can avoid redoing the bundle install step every time a file has changed
ADD lib/developer_portal/*.gemspec lib/developer_portal/
ADD vendor/active-docs/*.gemspec vendor/active-docs/
ADD Gemfile* ./
ADD Rakefile ./

RUN source /opt/app-root/etc/scl_enable \
    && gem install --no-document bundler:2.2.18 \
    && bundle config build.pg --with-pg-config=/usr/pgsql-10/bin/pg_config \
    && bundle install --verbose --deployment --jobs $(grep -c processor /proc/cpuinfo) --retry=5 --full-index

# Cache oracle gem dependencies. Those gems are open source and do not contain Oracle libraries
RUN source /opt/app-root/etc/scl_enable \
    && printf "source 'https://rubygems.org'\ngem 'activerecord-oracle_enhanced-adapter', '1.7.11'\ngem 'ruby-oci8', '2.2.6.1'\n" > Gemfile.oracle \
    && mv .bundle .bundle.bak \
    && BUNDLE_GEMFILE=Gemfile.oracle bundle package --no-install --all \
    && rm -rf Gemfile.oracle* .bundle \
    && mv .bundle.bak .bundle

# Copy the source code into container
ADD . ./

RUN source /opt/app-root/etc/scl_enable \
    && npm install -g yarn@1.22.0

RUN source /opt/app-root/etc/scl_enable \
    && yarn install:safe

RUN chgrp root /opt/system/ \
    && cp -pR config/docker/* ./config/ \
    && cp -pR openshift/system/config/* ./config/ \
    && cp -pR openshift/system/contrib/scl_enable /opt/app-root/etc/

RUN source /opt/app-root/etc/scl_enable \
   && bundle exec rake tmp:create \
   && mkdir -p public/assets db/sphinx \
   && chmod g+w -vfR log tmp public/assets db/sphinx \
   && chmod g+w /opt/system/config \
   && umask 0002 \
   && cd /opt/system \
   && bundle exec rake assets:precompile tmp:clear \
   && rm log/*.log \
   && rm -rf node_modules \
   && cp openshift/system/entrypoint.sh /opt/system/entrypoint.sh \
   && rm -rf /opt/system/openshift/system/sphinx*.rpm \
   && rm -rf /opt/system/vendor/oracle/ /opt/system/test/ /opt/system/spec/ /opt/system/features/ /opt/system/lib/proxy \
   && cp config/oracle/*.ini /etc/ \
   && rm -rf /var/cache/yum/* \
   && install -D /opt/system/doc/licenses/licenses.xml /root/licenses/3scale-amp-system-container/licenses.xml

USER 1001

ENTRYPOINT ["/opt/system/entrypoint.sh"]
CMD ["unicorn", "-c", "config/unicorn.rb", "-E", "${RAILS_ENV}", "config.ru"]
