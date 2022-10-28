# Manual setup on Fedora (34)

## Language and runtime version management

In order to manage the required languages and runtime: Ruby, Python and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/introduction.html). See its [getting started](https://asdf-vm.com/guide/getting-started.html) guide in order to get specific instructions for your SHELL and installation method.

Once installed, use the provided `.tool-versions.sample` file to get the appropriate versions.
```
ln -s .tool-versions.sample .tool-versions
```

## Ruby and Node.js

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

## Dependencies

```
sudo yum install patch autoconf automake bison libffi-devel libtool libyaml-devel readline-devel sqlite-devel zlib-devel openssl-devel ImageMagick ImageMagick-devel mysql-devel postgresql-devel chromedriver memcached

sudo systemctl restart memcached
```

## Database (Postgres / MySQL / Oracle)

Postgres, MySQL or Oracle has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```
docker run -d -p 3306:3306 -e MYSQL_ALLOW_EMPTY_PASSWORD=true --name mysql57 mysql:5.7
```

Alternatively, you can run Postgres directly on your machine by following [this article](https://developer.fedoraproject.org/tech/database/postgresql/about.html).

## Sphinx Search

Install package and run it

```
sudo dnf install sphinx
bundle exec rake ts:configure ts:start
```

## Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```
docker run -d -p 6379:6379 redis
```

Alternatively, you can run Redis directly on your machine by using `yum`:

```
sudo yum install redis

sudo systemctl restart redis
```

## Eventmachine

Eventmachine has to be installed with `--with-cppflags=-I/usr/include/openssl/`. Simply run:

```
bundle config build.eventmachine --with-cppflags=-I/usr/include/openssl/
```

## Bundler
We manage our gems with [Bundler](https://bundler.io/). Install it by running:

```
gem install bundler
```

Then install all required Ruby gems:

```
bundle install
```

## Yarn (1.x)

To manage our JavaScript packages we use [Yarn](https://yarnpkg.com/). It is recommended to install it with NPM:
```
npm install --global yarn
```

> See other ways to install it, such as with `brew`, at https://classic.yarnpkg.com/en/docs/install.

Then install all required packages:

```
yarn install
```

## Config files

Copy example config files from the examples folder:

```
cp config/examples/* config/
```
