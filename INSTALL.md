# INSTALL

Follow these instructions to set up a development environment, build and deploy this project on your machine.

## Clone the repo

```bash
git clone https://github.com/3scale/porta.git
```

## Setup
#### Containers

[Setup with containers](./containers_setup.md)

#### Manual setup

[Manual setup on MacOS](./osx-manual-setup.md)

[Manual setup on Fedora](./fedora-manual-setup.md)

## Setup Database

The database needs to be created and initialized. To do so run:

```sh
bundle exec rake db:setup
```

This command will seed the application with multi-tenant, buyer and developer accounts which will be accessible at: `http://master-account.3scale.localhost:3000/`, `http://provider-admin.3scale.localhost:3000/`, `http://provider.3scale.localhost:3000/` respectively. Take note of the credentials generated at this moment in order to log in to each of the portals above.

It's also possible to have a custom setup by means of environment variables. These can be found at `db/seed.rb` although here are the most often used ones:

```sh
MASTER_PASSWORD=p               # Multi-tenant account password
USER_PASSWORD=p                 # Buyer account password
ADMIN_ACCESS_TOKEN=secret       # Admin access token
APICAST_ACCESS_TOKEN=secret     # Apicast access token
```

> To set the database up from scratch again, use `db:reset` to drop and create it:
>
> ```sh
> bundle exec rake db:reset
> ```

## Run porta

Install all dependencies:
```
bundle && yarn
```

Start the rails server by running the following command:

```bash
rails server -b 0.0.0.0 # Runs the server, available at localhost:3000
```

## Rails 7.2 / 8.0 dual boot

The default bundle uses Rails 7.2. `Gemfile.next` is a symlink to `Gemfile`;
selecting it activates the Rails 8.0 dependency constraints and its separate
`Gemfile.next.lock`. Both bundles use Ruby 3.3, Rack 2.2, and the existing
framework defaults.

Install both bundles:

```sh
bundle install
BUNDLE_GEMFILE=Gemfile.next bundle install
```

Select the bundle for each command, including database preparation, asset
compilation, the server, and tests:

```sh
# Current Rails
bundle exec rails runner 'puts Rails.version'
bundle exec rails test
bundle exec rspec
bundle exec cucumber

# Next Rails
BUNDLE_GEMFILE=Gemfile.next bundle exec rails runner 'puts Rails.version'
BUNDLE_GEMFILE=Gemfile.next bundle exec rails test
BUNDLE_GEMFILE=Gemfile.next bundle exec rspec
BUNDLE_GEMFILE=Gemfile.next bundle exec cucumber
BUNDLE_GEMFILE=Gemfile.next bundle exec rails server -b 0.0.0.0
```

Prefix any existing development command with `BUNDLE_GEMFILE=Gemfile.next` to
use Rails 8.0. Use `NextRails.next?` in application code only when compatibility
requires different implementations for the two versions. Keep changes that work
on both versions unconditional. Update each lockfile with its matching bundle;
do not overwrite `Gemfile.next.lock` with the current lockfile after initial setup.

Rails deprecation warnings remain visible. CircleCI automatically sets
`DEPRECATION_TRACKER=save` in the `_rails80` test jobs, so Minitest and RSpec save
per-test inventories. Tracking remains opt-in for Rails 7.2 and local runs:

```sh
DEPRECATION_TRACKER=save bundle exec rails test
BUNDLE_GEMFILE=Gemfile.next DEPRECATION_TRACKER=save bundle exec rspec
```

Inventories are written to `log/deprecations-<runner>-<Rails version>-<node>.json`,
separating Rails versions and CircleCI nodes. CircleCI collects these files with
its log artifacts. These inventories record warnings
emitted during tests; also review warnings emitted while the application boots.

CircleCI keeps the existing Rails 7.2 workflows and adds `_rails80` counterparts
for MySQL, PostgreSQL, and Oracle, including nightly builds. Approve the desired
database/version workflow using its existing manual approval step. Each version
runs asset compilation, Minitest, RSpec, and Cucumber with the same bundle, in a
separate workspace with separate gem and asset caches. The Rails 8.0 workflows
expose remaining upgrade failures; adding dual boot does not mean the application
or its full test suite is already compatible with Rails 8.0.

Before switching the default bundle, update Rails 7.2 to its latest patch,
establish a green baseline, resolve deprecations, and fix the failures exposed by
Rails 8.0 on all databases. Change `config.load_defaults` separately after the
version upgrade is complete.

## Sphinx server

Some models are indexed by [Sphinx](http://sphinxsearch.com/) (see app/indices). The search server needs to be running in the background to enable searching through these models. Start it in a separate terminal by running:

```sh
bundle exec rake ts:configure ts:start
```

## Asset compilation

Before running the application, all assets need to be compiled and a manifest generated. To do that run:

```sh
bundle exec rails assets:precompile
```

This will include both the rails assets pipeline and webpack and it's intended for production and tests.
For development, if you're gonna change anything under app/javascript or app/assets/stylesheets, it's more convenient to use live code reloading:

```sh
yarn dev
```

This will re-compile webpack and CSS after changes are saved and reload the browser.

#### Environment variables

Customize your server with the following environment variables:
| Env var | Description | Example |
| - | - | - |
| APICAST_REGISTRY_URL | An endpoint to get Apicast policies| https://apicast.example.com/policies |
| PROMETHEUS_EXPORTER_PORT | Prometheus port | 9398 |
| CONFIG_INTERNAL_API_USER | Queried in config/core.yml, must match APIsonator configuration  | system_app |
| CONFIG_INTERNAL_API_PASSWORD | Queried in config/core.yml, must match APIsonator configuration | token |
| ZYNC_AUTHENTICATION_TOKEN | Queried in config/zync.yml | token |
| ZYNC_ENDPOINT | Queried in config/zync.yml | http://127.0.0.1:5000 |
