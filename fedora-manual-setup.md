# Manual setup on Fedora (36)

### Language and runtime version management

In order to manage the required languages and runtime: Ruby, Python and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/introduction.html). See its [getting started](https://asdf-vm.com/guide/getting-started.html) guide in order to get specific instructions for your SHELL and installation method.

Once installed, use the provided `.tool-versions.sample` file to get the appropriate versions.

```
ln -s .tool-versions.sample .tool-versions
```

### Ruby and Node.js

The project supports **[ruby 2.7.x](https://www.ruby-lang.org/en/downloads/)** and **[Node.js 14](https://nodejs.org/download/release/v14.21.3/)**.
The recommended way to install them is with `asdf`:

```
asdf plugin add ruby
asdf plugin add nodejs

asdf install
```

> Alternatively, Node.js can be installed as a [Module](https://developer.fedoraproject.org/tech/languages/nodejs/nodejs.html):
> ```
> dnf module install nodejs:14
> ```

### Dependencies

```
sudo dnf install sphinx chromedriver postgresql-devel gd-devel mysql-devel openssl-devel zlib-devel sqlite-devel readline-devel libyaml-devel libtool libffi-devel bison automake autoconf patch
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
podman run -d -p 6379:6379 redis:6.2-alpine
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

### Bundler

Ruby gems are managed with [Bundler](https://bundler.io/). Install it by running:

```
gem install bundler
```

And install all gems:

```
bundle install
```

> It's possible that eventmachine installation fails. If so, try adding the following config:
>
> ```sh
> bundle config build.eventmachine --with-cppflags="-I/usr/include/openssl/"
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
