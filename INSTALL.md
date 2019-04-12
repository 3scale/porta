# INSTALL

Follow these instructions in order to set up a development environment, build and deploy this project on your machine.

## Clone the repo, including submodules

This project uses [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so please ensure you include them by simply adding `--recurse-submodules`:

```bash
git clone --recurse-submodules https://github.com/3scale/porta.git
``` 

## Quick Setup with Docker

We provide a dockerized environment that you can use to run the test suite or to run this project 
locally on your machine, without needing to install anything on your host OS (e.g. if you are not 
planning to do long term development work).

The project relies on a [`Makefile`](https://www.gnu.org/software/make/manual/html_node/Introduction.html) for its build process. Check a complete list of available tasks by running:

```bash
make help
```

##### Running Tests
Download and build all the images and run the test suite in the container:
```bash
make test
```

##### Entering a Running Container
Download and build all the images and start a shell session inside the container:
```bash
make bash
```

All the source and dependencies for this project will be in place, making possible to run porta and the tests from inside the container. See [Run Porta](#run-porta)

## Manual setup on Mac OS X (10.13)

### Prerequisites

#### Ruby version

The project supports **Ruby 2.3.x**.

Verify you have a proper version by running on your terminal:
```bash
ruby -v
```

> Mac OS X 10.13 comes with 2.3.7 but you might also use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install your own ruby version.

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
You can download all Xcode versions from the [Apple's developer site](https://developer.apple.com/download/more/?name=Xcode).

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

#### Spring (Optional)
[Spring](https://github.com/rails/spring) is a Rails application preloader. It speeds up development by keeping your application running in the background so you don't need to boot it every time you run a test, rake task or migration.

This is not required but still recommended. Install it via gem:
```shell
gem install spring -v 2.0.0
```

#### Sphinx Search

[Sphinx](http://sphinxsearch.com/) has to be installed with **mysql@5.7**:

```shell
sed -i '' -e 's|depends_on "mysql"|depends_on "mysql@5.7"|g' /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/sphinx.rb
brew install sphinx
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

#### Setup Database

Finally initialize the database with some seed data by running:

```bash
bundle exec rake db:setup
```

You may need to set the database up from scratch again, in that case use `db:reset` to drop it first too:

```bash
bundle exec rake db:reset # This will drop and setup the database
```

### Run Porta
Start up the rails server by running the following command:
```bash
$ UNICORN_WORKERS=2 rails server -b 0.0.0.0 # Runs the server, available at localhost:3000
```
> The number of unicorn workers is variable and sometimes it will need more than 2. In case the server is slow or start suffering from timeouts, try restarting porta with a higher number like 8.
