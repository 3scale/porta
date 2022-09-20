# INSTALL

Follow these instructions to set up a development environment, build and deploy this project on your machine.

## Clone the repo

```bash
git clone https://github.com/3scale/porta.git
```

## Quick Setup with Docker

We provide a dockerized environment that you can use to run the test suite or to run this project locally on your machine, without needing to install anything on your host OS (e.g. if you are not planning to do long term development work).

The project relies on a [`Makefile`](https://www.gnu.org/software/make/manual/html_node/Introduction.html) for its build process. Check a complete list of available tasks by running:

```bash
make help
```

### Entering a Running Container

Download and build all the images and start a shell session inside the container:

```bash
make bash
```

All the sources and dependencies for this project will be in place, making it possible to run porta and the tests from inside the container. See [Run Porta](#run-porta)

### Running the application

It's also possible to run the application by using only Docker. Firstly, set up the database by running `dev-setup` from your terminal:

```
MASTER_PASSWORD=<master_password> USER_PASSWORD=<user_password> make dev-setup
```

then install all dependencies and run the application with `dev-start`:

```
make dev-start
```

or, you can run the setup and run with

```
make default
```

to stop the application, run:

```
make dev-stop
```

## Manual setup on MacOS (12.5.1)

### Prerequisites

#### Package and runtime version management

To add all required missing packages, make sure you have [Homebrew](https://brew.sh/) installed in your machine.

To manage the required runtimes, such as Ruby and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/getting-started.html#global). Install it with brew:
```
brew install asdf
```

> Don't forget to add to your ~/.zshrc:
>
> ```bash
> echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
> ```

And use the provided `.tool-versions.sample` file to use the appropriate versions.
```
ln -s .tool-versions.sample .tool-versions
```

#### Python (only M1 macs)
The project requires Python 2.7.18. However, it is not included anymore in Apple macs with Silicon. We recommend to handle Python installation with `asdf`:

```
asdf plugin add python

asdf install
```

#### Ruby and Node.js

The project supports **[ruby 2.6.x](https://www.ruby-lang.org/en/downloads/)** and **[Node.js 12](https://nodejs.org/en/download/)**.
The recommended way to install them is with `asdf`:

```
asdf plugin add ruby
asdf plugin add nodejs

asdf install
```

#### Xcode

Install Xcode from the App Store. Then run the following command from your terminal to install Command Line Tools:
```
xcode-select —install
```

> Older versions of Xcode are available at [Apple's developer site](https://developer.apple.com/download/all/?q=xcode).

#### Dependencies

```
brew install
brew install chromedriver imagemagick@6 mysql@5.7 gs pkg-config openssl geckodriver postgresql@14 memcached
brew link mysql@5.7 --force
brew link imagemagick@6 --force
brew services start mysql@5.7
```

For M1 macs you will also need:
```
brew install pixman cairo pango
```

> Depending on your needs, you may want use `postgresql` instead of `mysql`.
>
> ```
> brew services start postgresql@14
> ```

#### Sphinx Search
Install [Sphinx](http://sphinxsearch.com/) for **mysql@5.7** with Homebrew:
```
brew install sphinx
```

#### Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```
docker run -d -p 6379:6379 redis
```

Alternatively, you can run Redis directly on your machine by using `brew`:

```
brew install redis
brew services start redis
```

### Setup

#### Config files

Copy example config files from the examples folder:

```
cp config/examples/* config/
```

#### Bundler

Install [Bundler](https://bundler.io/) to manage all required Ruby gems:
```
gem install bundler
```

Then configure the bundle config with:
```bash
bundle config --global build.eventmachine --with-cppflags="-I$(brew --prefix openssl)/include"
bundle config --global build.mysql2 --with-opt-dir="$(brew --prefix openssl)"
bundle config --local build.github-markdown --with-cflags=-Wno-error=implicit-function-declaration
bundle config --local build.thin --with-cflags=-Wno-error=implicit-function-declaration
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
> you can fix it setting the flags:
>
> ```bash
> bundle config --local build.mysql2 --with-ldflags="-L$(brew --prefix openssl)/lib" --with-cppflags="-I$(brew --prefix openssl)/include"
> ```
>
> and run `bundle install` again.

#### Yarn

Install [Yarn](https://yarnpkg.com/) to manage all required Javscript packages:

```
brew install yarn
```

And install them:

```
yarn install
```

## Manual setup on Fedora (34)

### Prerequisites

#### Package and runtime version management

To manage the required runtimes, such as Ruby and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/introduction.html). See its [getting started](https://asdf-vm.com/guide/getting-started.html) guide in order to get specific instructions for your SHELL and installation method.

Once installed, use the provided `.tool-versions.sample` file to get the appropriate versions.
```
ln -s .tool-versions.sample .tool-versions
```

#### Ruby and Node.js

The project supports **[ruby 2.6.x](https://www.ruby-lang.org/en/downloads/)** and **[Node.js 12](https://nodejs.org/en/download/)**.
The recommended way to install them is with `asdf`:

```
asdf plugin add ruby
asdf plugin add nodejs

asdf install
```

> Alternatively, Node.js can be installed as a [Module](https://developer.fedoraproject.org/tech/languages/nodejs/nodejs.html):
> ```
> dnf module install nodejs:12
> ```

#### Dependencies

```
sudo yum install patch autoconf automake bison libffi-devel libtool libyaml-devel readline-devel sqlite-devel zlib-devel openssl-devel ImageMagick ImageMagick-devel mysql-devel postgresql-devel chromedriver memcached

sudo systemctl restart memcached
```

#### Database (Postgres / MySQL / Oracle)

Postgres, MySQL or Oracle has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```
docker run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql57 mysql:5.7
```

Alternatively, you can run Postgres directly on your machine by following [this article](https://developer.fedoraproject.org/tech/database/postgresql/about.html).

#### Sphinx Search

Install package and run it

```
sudo dnf install sphinx
bundle exec rake ts:configure ts:start
```

#### Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```
docker run -d -p 6379:6379 redis
```

Alternatively, you can run Redis directly on your machine by using `yum`:

```
sudo yum install redis

sudo systemctl restart redis
```

### Setup

#### Eventmachine

Eventmachine has to be installed with `--with-cppflags=-I/usr/include/openssl/`. Simply run:

```
bundle config build.eventmachine --with-cppflags=-I/usr/include/openssl/
```

#### Config files

Copy example config files from the examples folder:

```
cp config/examples/* config/
```

#### Bundle

Run [Bundler](https://bundler.io/) to install all required Ruby gems:

```
bundle install
```

#### Node packages

Install [Yarn](https://yarnpkg.com/):

```
npm install --global yarn
```


Run [Yarn](https://www.yarnpkg.com/) to install all the required dependencies:

```
yarn install
```

## Rails cache

Rails cache is enabled by default for development, and uses a memcached instance that must be listening at `localhost:11211`.
However, you might need to disable it in your environment. It can be switched off by updating `config/cache_store.yml` to this:

```bash
development:
  - :null_store
```

## Setup Database

Finally, initialize the database with some seed data by running:

```
bundle exec rake db:setup
```

You may need to set up the database from scratch again, in that case, use `db:reset` to drop it first too:

```bash
bundle exec rake db:reset # This will drop and set up the database
```

### Generating credentials

Command above will seed the application and create the Master, Provider & Developer accounts that are accessible through: `http://master-account.3scale.localhost:3000/`, `http://provider-admin.3scale.localhost:3000/`, `http://provider.3scale.localhost:3000/` respectively. Take note of the credentials generated at this moment, to log in to each of the portals above.

Alternatively you can set environment variables before running command to have predictable setup. For more you can look at `db/seed.rb`.

```bash
MASTER_PASSWORD=p
USER_PASSWORD=p # this is provider admin password
ADMIN_ACCESS_TOKEN=secret
APICAST_ACCESS_TOKEN=secret
```

## Run Porta

Startup the rails server by running the following command:

```bash
$ env UNICORN_WORKERS=2 rails server -b 0.0.0.0 # Runs the server, available at localhost:3000
```

> The number of unicorn workers is variable and sometimes it will need more than 2. In case the server is slow or start suffering from timeouts, try restarting porta with a higher number like 8.

### Environment

You can modify behavior with the following environment variables.

```bash
APICAST_REGISTRY_URL=https://apicast-staging.proda.3sca.net/policies
# modify Prometheus port in case of a conflict
PROMETHEUS_EXPORTER_PORT=9398
# queried in config/core.yml, must match APIsonator configuration
CONFIG_INTERNAL_API_USER=system_app
CONFIG_INTERNAL_API_PASSWORD=token
# queried in config/zync.yml
ZYNC_AUTHENTICATION_TOKEN=token
ZYNC_ENDPOINT=http://127.0.0.1:5000
```
