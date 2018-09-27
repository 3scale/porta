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

All the source and dependencies for this project will be in place, allowing you to run the server and the tests from inside the container:
```bash
$ bundle exec rake integrate # Runs the test suite
$ APICAST_REGISTRY_URL=https://apicast-staging.proda.3sca.net/policies UNICORN_WORKERS=2 rails server -b 0.0.0.0 # Runs the server, available at localhost:3000
```

## Setting up your Development Environment on Mac OS X (10.13)

### Prerequisites

#### Ruby version

The project supports **Ruby 2.3.x**.

Verify you have a proper version by running on your terminal:
```bash
ruby -v
```

> Mac OS X 10.13 comes with 2.3.7 but you might also use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install your own ruby version.

#### Xcode

It's required to have **Xcode 9.4** installed, newer versions are not compatible with some dependencies (read more about this [here](https://github.com/thoughtbot/capybara-webkit/issues/1071)).

You can download all Xcode versions from the [Apple's developer site](https://developer.apple.com/download/more/?name=Xcode).

#### Dependencies

Make sure you have [Homebrew](https://brew.sh/) in your machine in order to install the following dependencies:

```shell
brew install imagemagick@6 qt@5.5 mysql@5.7 gs pkg-config openssl
brew link qt@5.5 --force
brew link mysql@5.7 --force
brew link imagemagick@6 --force
```

#### XQuartz

To be able to run [Cucumber](https://cucumber.io/) tests you also need [XQuartz](http://xquartz.macosforge.org/landing/).

#### Spring (Optional)
[Spring](https://github.com/rails/spring) is a Rails application preloader. It speeds up development by keeping your application running in the background so you don't need to boot it every time you run a test, rake task or migration.

This is not required but still recommended. Install it via gem:
```shell
gem install spring -v 2.0.0
```

#### Sphinx Search

[Sphinx](http://sphinxsearch.com/) has to be installed with **mysql@5.7**:
```shell
brew install sphinx --with-mysql@5.7
```

Make sure your Sphinx configuration has the following changes applied:
```patch
diff --git i/Formula/sphinx.rb w/Formula/sphinx.rb
index 1c4cc0e5b..2201bc43c 100644
--- i/Formula/sphinx.rb
+++ w/Formula/sphinx.rb
@@ -16,11 +16,13 @@ class Sphinx < Formula
 
   option "with-mysql", "Force compiling against MySQL"
   option "with-postgresql", "Force compiling against PostgreSQL"
+  option "with-mysql@5.7", "Force compiling against MySQL 5.7"
 
   deprecated_option "mysql" => "with-mysql"
   deprecated_option "pgsql" => "with-postgresql"
 
   depends_on "mysql" => :optional
+  depends_on "mysql@5.7" => :optional
   depends_on "openssl" if build.with? "mysql"
   depends_on "postgresql" => :optional
 
@@ -47,7 +49,7 @@ class Sphinx < Formula
       --with-libstemmer
     ]
 
-    if build.with? "mysql"
+    if build.with?("mysql") || build.with?("mysql@5.7")
       args << "--with-mysql"
     else
       args << "--without-mysql"
```

Run `brew edit sphinx` to edit Sphinx configuration or alternatively open `${HOMEBREW_PREFIX:-/usr/local}/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/sphinx.rb` with your favorite editor.

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
