# Manual setup on MacOS (12.5.1)

## Homebrew

To add all required missing package, make sure you have [Homebrew](https://brew.sh/) installed in your machine.

## Languages and runtime versions management

In order to manage the required languages and runtime: Ruby, Python and Node.js, we recommend using [asdf](https://asdf-vm.com/guide/getting-started.html#global). Install it with brew:
```
brew install asdf
```

> Don't forget to add to your ~/.zshrc:
>
> ```bash
> echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
> ```

Then link the provided `.tool-versions.sample` file to make sure you use the supported versions. Otherwise the app could throw unexpected errors.
```
ln -s .tool-versions.sample .tool-versions
```

### Ruby and Node.js

The project supports **[ruby 2.6.x](https://www.ruby-lang.org/en/downloads/)** and **[Node.js 12](https://nodejs.org/en/download/)**.
The recommended way to install them is with `asdf`:

```
asdf plugin add ruby
asdf plugin add nodejs

asdf install
```

### Python (only M1 macs)
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

> Older versions of Xcode are available at [Apple's developer site](https://developer.apple.com/download/all/?q=xcode).

### Dependencies

```
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

### Sphinx Search
Install [Sphinx](http://sphinxsearch.com/) for **mysql@5.7** with Homebrew:
```
brew install sphinx
```

### Redis

[Redis](https://redis.io) has to be running for the application to work. The easiest way to do it is in a [Docker](https://www.docker.com/) container by simply running:

```
docker run -d -p 6379:6379 redis
```

Alternatively, you can run Redis directly on your machine by using `brew`:

```
brew install redis
brew services start redis
```

### Bundler

We manage our gems with [Bundler](https://bundler.io/). Install it by running:

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

### Yarn (1.x)

To manage our JavaScript packages we use [Yarn](https://yarnpkg.com/). It is recommended to install it with NPM:
```
npm install --global yarn
```

> See other ways to install it, such as with `brew`, at https://classic.yarnpkg.com/en/docs/install.

Then install all required packages:

```
yarn install
```

### Config files

Copy all the default config files from the examples folder:

```
cp config/examples/* config/
```
