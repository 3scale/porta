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

The database need to be created and initialized. To do so run:

```sh
bundle exec rake db:setup
```

This command will seed the application with the multi-tenant, a buyer and a developer accounts which will be accessible at: `http://master-account.3scale.localhost:3000/`, `http://provider-admin.3scale.localhost:3000/`, `http://provider.3scale.localhost:3000/` respectively. Take note of the credentials generated at this moment in order to log in to each of the portals above.

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

And the rails server up by running the following command:

```bash
$ env UNICORN_WORKERS=2 rails server -b 0.0.0.0 # Runs the server, available at localhost:3000
```

> The number of unicorn workers is variable and sometimes it will need more than 2. In case the server is slow or start suffering from timeouts, try restarting porta with a higher number like 8.

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
For development, if you're gonna change anything under app/javascript like React or Typescript, it's more convenient to use live code reloading:

```sh
bundle exec rails webpack:dev
```

This will re-compile webpack and reload the browser whenever a file under app/javascript is updated.

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
