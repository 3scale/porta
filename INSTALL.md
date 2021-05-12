# INSTALL

Follow these instructions to set up a development environment, build and deploy this project on your machine.

## Clone the repo, including submodules

This project uses [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so please ensure you include them by simply adding `--recurse-submodules`:

```bash
git clone --recurse-submodules https://github.com/3scale/porta.git
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

## Manual setup on Mac OS X (10.13 - 11.0)

### Prerequisites

#### Ruby version

The project supports **2.5.x**.

Verify you have a proper version by running on your terminal:

```bash
ruby -v
```

> We recommend using [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install any ruby version.

Example with RVM:
```bash
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
rvm install 2.5
```

#### Node version

The project supports **Version: 10.X.X**.

You might want to use [nvm](https://github.com/creationix/nvm/) to install and work with specific Node versions:

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
```

Restart the terminal and install Node:

```bash
nvm install 10 && nvm use 10
```

###### As an alternative for Mac OS, and if you don't want multiple Node versions, you could use homebrew:

```bash
brew install node@10
```

#### Xcode

Install Xcode from the App Store.
You can download all Xcode versions from [Apple's developer site](https://developer.apple.com/download/more/?name=Xcode).

#### Dependencies

Make sure you have [Homebrew](https://brew.sh/) in your machine to install the following dependencies:

```shell
brew tap homebrew/cask
brew cask install chromedriver
brew install imagemagick@6 mysql@5.7 gs pkg-config openssl geckodriver postgresql memcached
brew link mysql@5.7 --force
brew link imagemagick@6 --force
brew services start mysql@5.7
```

Optionally, depending on your needs you can launch memcached and postgresql services

```shell
brew services start memcached postgresql
```

#### Sphinx Search

[Sphinx](http://sphinxsearch.com/) has to be installed with **mysql@5.7** and compiled from source:

```shell
sed -i '' -e 's|depends_on "mysql"|depends_on "mysql@5.7"|g' /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/sphinx.rb
brew install --build-from-source sphinx
```

#### Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```shell
docker run -d -p 6379:6379 redis
```

Alternatively, you can run Redis directly on your machine by using `brew`:

```shell
brew install redis
brew services start redis
```

### Setup

#### Eventmachine

Eventmachine has to be installed with `--with-cppflags=-I/usr/local/opt/openssl/include`. Simply run:

```shell
bundle config build.eventmachine --with-cppflags=-I/usr/local/opt/openssl/include
```

#### Config files

Copy example config files from the examples folder:

```shell
cp config/examples/* config/
```

#### Bundle

On MacOS 10.15 or newer, first configure the bundle config with:
```shell
bundle config --global build.eventmachine --with-cppflags=-I/usr/local/opt/openssl/include
bundle config --global build.mysql2 "--with-opt-dir=/usr/local/opt/openssl"
bundle config --local build.github-markdown --with-cflags="-Wno-error=implicit-function-declaration"
bundle config --local build.thin --with-cflags="-Wno-error=implicit-function-declaration"
```

Run [Bundler](https://bundler.io/) to install all required Ruby gems:

```shell
bundle install
```

If the `mysql2` gem installation fails with the error:

```
ld: library not found for -lssl
```

you can fix it setting the flags:

```shell
bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include"
```

and run `bundle install` again.

#### Node packages

Install [Yarn](https://yarnpkg.com/):

```bash
brew install yarn
```


Run [Yarn](https://www.yarnpkg.com/) to install all the required dependencies:

```bash
yarn install
```

## Manual setup on Fedora (29)

### Prerequisites

#### Ruby version

The project supports **2.5.x**.

Verify you have a proper version by running on your terminal:

```bash
ruby -v
```

> You can use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install ruby.

#### Node version

The project supports **Version: 8.X.X**.

Install Node version 8 and ensure that the node is properly configured in the `PATH` environment variable.

#### Dependencies

```shell
sudo yum install patch autoconf automake bison libffi-devel libtool libyaml-devel readline-devel sqlite-devel zlib-devel openssl-devel ImageMagick ImageMagick-devel mysql-devel postgresql-devel chromedriver memcached

sudo systemctl restart memcached
```

#### Database (Postgres / MySQL / Oracle)

Postgres, MySQL or Oracle has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```shell
docker run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql57 mysql:5.7 
```

Alternatively, you can run Postgres directly on your machine by following [this article](https://developer.fedoraproject.org/tech/database/postgresql/about.html).

#### Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```shell
docker run -d -p 6379:6379 redis
```

Alternatively, you can run Redis directly on your machine by using `yum`:

```shell
sudo yum install redis

sudo systemctl restart redis
```

### Setup

#### Eventmachine

Eventmachine has to be installed with `--with-cppflags=-I/usr/include/openssl/`. Simply run:

```shell
bundle config build.eventmachine --with-cppflags=-I/usr/include/openssl/
```

#### Config files

Copy example config files from the examples folder:

```shell
cp config/examples/* config/
```

#### Bundle

Run [Bundler](https://bundler.io/) to install all required Ruby gems:

```shell
bundle install
```

#### Node packages

Install [Yarn](https://yarnpkg.com/):

```bash
brew install yarn
```


Run [Yarn](https://www.yarnpkg.com/) to install all the required dependencies:

```bash
yarn install
```

## Setup Database

Finally, initialize the database with some seed data by running:

```bash
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
