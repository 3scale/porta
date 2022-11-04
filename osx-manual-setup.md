# Manual setup on MacOS (12.5.1)

### Homebrew

To add all required missing package, make sure [Homebrew](https://brew.sh/) is installed in your machine.

### Languages and runtime versions management

In order to manage the required languages and runtime: Ruby, Python and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/getting-started.html#global). Install it with brew:

```
brew install asdf
```

> Don't forget to add to your ~/.zshrc:
>
> ```sh
> echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
> ```

Then link the provided `.tool-versions.sample` file to make sure the supported versions are used. Otherwise the app could throw unexpected errors.

```
ln -s .tool-versions.sample .tool-versions
```

### Ruby and Node.js

The project supports **[ruby 2.6.x](https://www.ruby-lang.org/en/downloads/)** and **[Node.js 10](https://nodejs.org/en/download/)**.
The recommended way to install them is with `asdf`:

```
asdf plugin add ruby
asdf plugin add nodejs

asdf install
```

* **Macs with M1** require installing and running node through Rosetta 2:

  ```
  arch -x86_64 asdf install nodejs 10.19.0
  ```

### Python (only macs with M1)

The project requires Python 2.7.18. However, it is not included anymore in Apple macs with Silicon. We recommend to handle Python installation with `asdf`:

```
asdf plugin add python

asdf install
```

### Xcode and Command Line Tools

Install Xcode from the App Store. Then run the following command from your terminal to install Command Line Tools:

```
xcode-select -—install
```

* In **Macs with M1**, recent versions of xcode are incompatible with older versions of ruby. You need to install Command Line Tools for Xcode 13.4. The installation file can be found at https://developer.apple.com/download/all/?q=command%20line%20tools%2013.4. It may be required to reboot your machine after installing it.

### Dependencies

```
brew install chromedriver imagemagick@6 gs pkg-config openssl geckodriver sphinx
brew link imagemagick@6
```

* **Macs with M1** also require de following:

  ```
  brew install pixman cairo pango
  ```

### Database

The application requires a database that can either be [PostgreSQL](https://www.postgresql.org), [MySQL](https://www.mysql.com) or [Oracle database](https://www.oracle.com/database/). We recommend running MySQL in a [Docker](https://www.docker.com/) container:

```sh
docker run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql57 mysql:5.7
```

Alternatively, both MySQL and PostgreSQL can be installed and managed by Homebrew
```sh
# MySQL
brew install mysql@5.7
brew link mysql@5.7 --force
brew services start mysql@5.7

# PostgreSQL
brew install postgresql@14
brew services start postgresql@14
```

### Redis

[Redis](https://redis.io) is an in-memory data store used as DB for some of the data and it has to be running for the application to work. We recommend running Redis in a [Docker](https://www.docker.com/) container:

```
docker run -d -p 6379:6379 redis
```

Alternatively, it be run directly on your machine with Homebrew:

```
brew install redis
brew services start redis
```

### Rails cache (Memcached)

If available, Redis will use [Memcached](https://www.memcached.org) for caching. Installing it is completely optional but still recommended. We recommend running memcached in a [Docker](https://www.docker.com/) container:

```
docker run -d -p 11211:11211 memcached
```

Alternatively, it can be run directly on your machine with Homebrew:

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

We manage Ruby gems with [Bundler](https://bundler.io/). Install it by running:

```
gem install bundler
```

Then add the necessary configs:

```sh
bundle config --local build.thin --with-cflags=-Wno-error="implicit-function-declaration"
bundle config --local build.github-markdown --with-cflags=-Wno-error="implicit-function-declaration"
bundle config --local build.mysql2 --with-opt-dir="$(brew --prefix openssl)"
```

And finally install all gems:

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

To manage our JavaScript packages we use [Yarn](https://classic.yarnpkg.com/lang/en/). It is recommended to install it with NPM:

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
