# INSTALL

Follow these instructions in order to set up a development environment, build and deploy this project on your machine.

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

All the source and dependencies for this project will be in place, making it possible to run porta and the tests from inside the container. See [Run Porta](#run-porta)

### Running the application

It's also possible to run the application by using only Docker. Firstly, setup the database by runnning `dev-setup` from your terminal:

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


## Manual setup on Mac OS X (10.13)

### Prerequisites

#### Ruby version

The project supports **Ruby 2.4.x**.

Verify you have a proper version by running on your terminal:
```bash
ruby -v
```

> Mac OS X 10.13 comes with 2.3.7 but you can also use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install your own ruby version.

#### Node version

The project supports **Version: 8.X.X**.

You might want to use [nvm](https://github.com/creationix/nvm/) to install and work with specific Node versions:

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
```

Restart the terminal and install Node:

```bash
nvm install 8
nvm use 8
```

###### As an alternative for Mac OS, and if you don't want multiple Node versions, you could use homebrew:

```bash
brew install node@8
```

#### Xcode

Install Xcode from the App Store.
You can download all Xcode versions from [Apple's developer site](https://developer.apple.com/download/more/?name=Xcode).

#### Dependencies

Make sure you have [Homebrew](https://brew.sh/) in your machine in order to install the following dependencies:

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

Alternatively you can run Redis directly on your machine by using `brew`:

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

Run [Bundler](https://bundler.io/) to install all required Ruby gems:

```shell
bundle install
```

If the `mysql2` gem installation fail with the error:

```
ld: library not found for -lssl
```

you can fix it setting the flags:

```shell
bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl/lib --with-cppflags=-I/usr/local/opt/openssl/include"
```

and run `bundle install` again.

#### NPM

Run [NPM](https://www.npmjs.com/) to install all the required Node modules:

```bash
npm install
```

## Manual setup on Fedora (29)

### Prerequisites

#### Ruby version

The project supports **Ruby 2.4.x**.

Verify you have a proper version by running on your terminal:
```bash
ruby -v
```

> You can use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install ruby.

#### Node version

The project supports **Version: 8.X.X**.

Install Node version 8 and ensure that the node is properly configured in `PATH` environment variable.

#### Dependencies

```shell
sudo yum install patch autoconf automake bison libffi-devel libtool libyaml-devel readline-devel sqlite-devel zlib-devel openssl-devel ImageMagick ImageMagick-devel mysql-devel postgresql-devel chromedriver memcached

sudo systemctl restart memcached
```

#### Database (Postgres / MySQL / Oracle)

Postgres, MySQL or Orcacle has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```shell
docker run -d -p 5433:5432 -e POSTGRES_USER=postgres -e POSTGRES_DB=3scale_system_development --name postgres10 circleci/postgres:10.5-alpine
```

Alternatively you can run Postgres directly on your machine by following [this article](https://developer.fedoraproject.org/tech/database/postgresql/about.html).

#### Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```shell
docker run -d -p 6379:6379 redis
```

Alternatively you can run Redis directly on your machine by using `yum`:

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

#### NPM

Run [NPM](https://www.npmjs.com/) to install all the required Node modules:

```bash
npm install
```

## Setup Database

Finally initialize the database with some seed data by running:

```bash
bundle exec rake db:setup
```

You may need to set up the database from scratch again, in that case use `db:reset` to drop it first too:

```bash
bundle exec rake db:reset # This will drop and setup the database
```

**NOTE:** This will seed the application and creates the Master, Provider & Developer accounts which are accessible through: `http://master-account.example.com.lvh.me:3000`, `http://provider-admin.example.com.lvh.me:3000`, `http://provider.example.com.lvh.me:3000` respectively. Please take note of the credentials generated at this moment also so that you can log into each of these portals.

## Run Porta
Start up the rails server by running the following command:
```bash
$ env UNICORN_WORKERS=2 rails server -b 0.0.0.0 # Runs the server, available at localhost:3000
```
> The number of unicorn workers is variable and sometimes it will need more than 2. In case the server is slow or start suffering from timeouts, try restarting porta with a higher number like 8.
