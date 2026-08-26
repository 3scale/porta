# Manual setup on macOS (26.5)

### Homebrew

To add all required missing packages, make sure [Homebrew](https://brew.sh/) is installed on your machine.

### Xcode and Command Line Tools

Either install Xcode from the App Store or just the [command-line tools](https://developer.apple.com/documentation/xcode/installing-the-command-line-tools/) via terminal:

```
xcode-select --install
```

### Languages and runtime versions management

In order to manage the required languages and runtimes: Ruby, Python and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/getting-started.html#global). Install it with brew:

```
brew install asdf
```

Make sure to follow any [configuration steps](https://asdf-vm.com/guide/getting-started.html#_2-configure-asdf) specific to your system.

> Don't forget to add shims directory to path. Add the following to your RC file:
>
> ```sh
> export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
> ```

Finally, link or copy the provided `.tool-versions.sample` file to make sure the supported versions are used. Otherwise the app could throw unexpected errors.

```sh
ln -s .tool-versions.sample .tool-versions
# or
cp .tool-versions.sample .tool-versions
```

### Ruby, Node.js and Python

The project requires **[ruby 3.3](https://www.ruby-lang.org/en/downloads/)**, **[Node.js 24](https://nodejs.org/download/release/v24.11.1/)** and **[Python 3.13.13](https://www.python.org/downloads/release/python-31313/)**. These will be installed and managed nicely by `asdf`:

```
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add python https://github.com/danhper/asdf-python.git

asdf install
```

> The git-url part is optional, but [recommended](https://asdf-vm.com/manage/plugins.html#add).
>

### Dependencies

The following libraries are required. Be sure to pay attention to any caveats that are relevant to your system:

```
brew install mysql@8.0 postgresql@15 gd manticoresearch
```

* Additionally you need to install the **[LiberationSans](https://www.dafont.com/liberation-sans.font)** font. You can install it in `~/Library/Fonts` or globally in `/Library/Fonts`.

### Databases

The application requires a database that can either be [PostgreSQL](https://www.postgresql.org), [MySQL](https://www.mysql.com) or [Oracle database](https://www.oracle.com/database/). MySQL will be used by default.

###### MySQL

We recommend running it in a [Podman](https://podman.io/docs/installation#macos) container:

```sh
podman run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql80 mysql:8.0
```
* **Macs with M1** require the flag `--platform linux/x86_64`:

  ```
  podman run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql80 --platform linux/x86_64 mysql:8.0
  ```

Alternatively it can be run by Homebrew:
```
brew services start mysql@8.0
```

###### PostgreSQL

We recommend running it in a [Podman](https://podman.io/) container:

```sh
export DATABASE_URL=postgresql://postgres:@localhost:5433/circleci

podman run -d -p 5433:5432 -e POSTGRES_USER=postgres -e POSTGRES_DB=circleci --name postgres10 circleci/postgres:10.5-alpine
```

Alternatively it can be run by Homebrew:
```
brew services start postgresql@15
```

### Redis

[Redis](https://redis.io) is an in-memory data store used as DB for some of the data and it has to be running for the application to work. We recommend running it in a [Podman](https://podman.io/) container:

```
podman run -d -p 6379:6379 --name redis redis:7.2-alpine
```

Alternatively, Redis can be run directly on your machine with Homebrew:

```
brew install redis
brew services start redis
```

### Memcached

If available, Rails will use [Memcached](https://www.memcached.org) for caching. Installing it is completely optional but still recommended. We recommend running it in a [Podman](https://podman.io/) container:

```
podman run -d -p 11211:11211 memcached
```

Alternatively, Memcached can be run directly on your machine with Homebrew:

```
brew install memcached
brew services start memcached
```

> Rails cache is enabled by default for development. However, it can be switched off by updating `config/cache_store.yml`:
>
> ```yml
> development:
>   - :null_store
> ```

### Bundler

Ruby gems are managed with [Bundler](https://bundler.io/). Ruby 3.3 comes with it preinstalled by default.

First, set the following configs:

```sh
bundle config --local build.local-fastimage_resize --with-opt-dir="$(brew --prefix gd)"
```

Then install all gems:

```
bundle install
```

> If the `mysql2` gem installation fails with the error:
>
> ```
> ld: library not found for -lssl
> ```
>
> Try to fix it adding the following config:
>
> ```sh
> bundle config --local build.mysql2 --with-ldflags="-L$(brew --prefix openssl)/lib" --with-cppflags="-I$(brew --prefix openssl)/include"
> ```
>
> and run `bundle install` again.

### Yarn (1.x)

JavaScript packages are managed with [Yarn](https://classic.yarnpkg.com/lang/en/). Install it with NPM:

```
npm install --global yarn
```

> See other ways to install it, such as with `brew`, at https://classic.yarnpkg.com/en/docs/install.

Then install all required packages:

```
yarn install
```

### Config files

Copy all the default config files to your project's config folder:

```
cp config/examples/* config/
```
