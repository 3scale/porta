# Manual setup on Fedora (43+)

### Language and runtime version management

In order to manage the required languages and runtime: Ruby, Python and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/introduction.html). See its [getting started](https://asdf-vm.com/guide/getting-started.html) guide in order to get specific instructions for your SHELL and installation method.

Once installed, use the provided `.tool-versions.sample` file to get the appropriate versions.

```
ln -s .tool-versions.sample .tool-versions
```

### Ruby and Node.js

The project supports **[ruby 3.3.x](https://www.ruby-lang.org/en/downloads/)** and **[Node.js 24](https://nodejs.org/download/release/v24/)**.
The recommended way to install them is with `asdf`:

```
asdf plugin add ruby
asdf plugin add nodejs

asdf install
```

> Alternatively, Node.js can be installed as a [Module](https://developer.fedoraproject.org/tech/languages/nodejs/nodejs.html):
> ```
> dnf module install nodejs:24
> ```

> **Ruby 3.3.x:** If you see `error: unknown type name 'bool'` when building native gems, your
> Ruby was compiled without `HAVE_STDBOOL_H` in its build config. You can verify this with:
> ```sh
> grep HAVE_STDBOOL $(ruby -r rbconfig -e 'puts RbConfig::CONFIG["rubyarchhdrdir"]')/ruby/config.h
> ```
> If the define is missing, see the [Bundler](#bundler) section below for a per-gem workaround.
> Ruby 3.4.x fixed the stdbool shim unconditionally, so upgrading is the cleaner long-term fix.

### Podman short-name resolution

Fedora 43 ships with Podman in `enforcing` short-name mode, which requires an interactive TTY to
resolve unqualified image names (e.g. `mysql:8.0`). This breaks automated or non-interactive use.

```sh
mkdir -p ~/.config/containers/registries.conf.d
cat > ~/.config/containers/registries.conf.d/00-shortnames.conf << 'EOF'
short-name-mode = "permissive"
unqualified-search-registries = ["docker.io"]
EOF
```

### Dependencies

```
sudo dnf install chromedriver postgresql-devel gd-devel mysql-devel openssl-devel zlib-devel sqlite-devel readline-devel libyaml-devel libtool libffi-devel bison automake autoconf patch
```

### Database

The application requires a database that can either be [PostgreSQL](https://www.postgresql.org), [MySQL](https://www.mysql.com) or [Oracle database](https://www.oracle.com/database/). MySQL will be used by default.

###### MySQL

We recommend running it in a [Podman](https://podman.io/) container:

```sh
podman run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql80 mysql:8.0
```

### Redis

[Redis](https://redis.io) is an in-memory data store used as DB for some of the data and it has to be running for the application to work. We recommend running it in a [Podman](https://podman.io/) container:

```
podman run -d -p 6379:6379 --name redis72 redis:7.2-alpine
```

Alternatively, Redis can be run directly on your machine with `dnf`:

```
sudo dnf install redis
sudo systemctl restart redis
```

### Memcached

If available, Rails will use [Memcached](https://www.memcached.org) for caching. Installing it is completely optional but still recommended. We recommend running it in a [Podman](https://podman.io/) container:

```
podman run -d -p 11211:11211 memcached
```

Alternatively, Memcached can be run directly on your machine with `dnf`:

```
sudo dnf install memcached
sudo systemctl restart memcached
```

> Rails cache is enabled by default for development. However, it can be switched off by updating `config/cache_store.yml`:
>
> ```yml
> development:
>   - :null_store
> ```

Note: if you're using [porta-dev-tools](https://github.com/3scale-labs/porta-dev-tools), the service should be down before starting dependencies with it.

### Manticore Search
Manticore search is an open source full-text search engine. It started as a fork of Sphinx at the time its source code got closed.

To install it, see https://manticoresearch.com/install/. It can be locally installed. Or if you prefer, you can link `bin/searchd` wrapper shell executable to your user's `PATH` to run it as a container.

```
ln -s /absolute/path/porta/bin/searchd ~/.local/bin/
```

This approach should also be compatible with [porta-dev-tools](https://github.com/3scale-labs/porta-dev-tools).

### Bundler

Ruby gems are managed with [Bundler](https://bundler.io/). Install it by running:

```
gem install bundler
```

And install all gems:

```
bundle install
```

> It's possible that some native gem installations fail. Known workarounds:
>
> ```sh
> # eventmachine SSL headers (all Fedora versions)
> bundle config build.eventmachine --with-cppflags="-I/usr/include/openssl/"
> ```
>
> **Ruby 3.3.x (if `HAVE_STDBOOL_H` is missing from your build):** Apply the following config
> before running `bundle install`. It defines `HAVE_STDBOOL_H` in each affected gem's preprocessor
> flags so that Ruby's stdbool shim includes `<stdbool.h>` as intended. There is no global
> catch-all — each gem must be listed individually:
>
> ```sh
> bundle config build.bootsnap "--with-cppflags=-DHAVE_STDBOOL_H=1"
> bundle config build.commonmarker "--with-cppflags=-DHAVE_STDBOOL_H=1"
> bundle config build.hiredis-client "--with-cppflags=-DHAVE_STDBOOL_H=1"
> bundle config build.ruby-prof "--with-cppflags=-DHAVE_STDBOOL_H=1"
> bundle config build.unf_ext "--with-cppflags=-DHAVE_STDBOOL_H=1"
> ```

### Yarn (1.x)

JavaScript packages are managed with [Yarn](https://classic.yarnpkg.com/lang/en/). It is recommended to install it with NPM:

```
npm install --global yarn
```

> See other ways to install it, such as with `dnf`, at https://classic.yarnpkg.com/en/docs/install.

Then install all required packages:

```
yarn install
```

### Config files

Copy all the default config files to your project's config folder:

```
cp config/examples/* config/
```

### Setting up the test database

The test database is set up with:

```sh
RAILS_ENV=test bundle exec rake db:reset
```
