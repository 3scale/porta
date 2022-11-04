## Setup with containers

We provide a containerized environment that you can use to run the test suite or to run this project locally on your machine, without needing to install anything on your host OS (e.g. if you are not planning to do long term development work).

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

It's also possible to run the application by using only containers. Firstly, set up the database by running `dev-setup` from your terminal:

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
