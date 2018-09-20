# INSTALL

### Clone this repo (including submodules!)

This project uses [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so please ensure you download those too:   

```bash
git clone --recurse-submodules https://github.com/3scale/porta.git system-fresh
``` 

### Quick-start

Read on to see how to get up and running quickly!

#### Building with Make

Most 3scale projects rely on `Makefile`s for their build process. 
In the root of this project, just run: 
```bash
make
``` 

...and you will see all the available targets, with a short description for what each target does. 

Please feel free to study the `Makefile`, as the executable documentation of how this project is built.  

#### Running the tests

We have provided a dockerized environment that you can use to run the test suite or to run this project 
locally on your machine, without needing to install anything on your host OS (e.g. if you are not 
planning to do long term development work).  

This development environment is accessible through the below command:

```shell
make bash
```

This will download and build all the necessary containers, and open a shell script inside a container
where all the source and dependencies for this project are in place, allowing you to run the server, 
or the test suite.

To run the test suite, just use: 

```bash
make test
```  

If you want to get rid of this environment, just run `make clean`.


## Development Environment Setup on Mac OS X (10.13)

### Ruby version

The project supports Ruby 2.3.x
Mac OS X 10.13 comes with 2.3.7 but you might also use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to install your own ruby version.

### Dependencies

First you should install following things:

XCode: Install it via the Apple Store application or in [Apple's developer site](https://developer.apple.com/xcode/download/)
Install version 9.4 See https://github.com/thoughtbot/capybara-webkit/issues/1071

```shell
brew install imagemagick@6 qt@5.5 mysql@5.7 gs pkg-config openssl
brew link qt@5.5 --force
brew link mysql@5.7 --force
brew link imagemagick@6 --force
```

Also you'll need http://xquartz.macosforge.org/landing/ to run cucumber tests.


### Installing Sphinx Search

Apply this patch to `${HOMEBREW_PREFIX:-/usr/local}/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/sphinx.rb`

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

You can also use `brew edit sphinx` and apply the modified lines

Then install sphinx with mysql@5.7 version

```shell
brew install sphinx --with-mysql@5.7
```


### Pre setup

Eventmachine should be installed with `--with-cppflags=-I/usr/local/opt/openssl/include`.

```shell
bundle config build.eventmachine --with-cppflags=-I/usr/local/opt/openssl/include
```

### Setup

Copy examples config:

```shell
cd porta
cp config/examples/* config/
bundle install
bundle exec rake db:setup
```
