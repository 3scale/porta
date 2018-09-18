# INSTALL

### Clone this repo (including submodules!)

This project uses [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so please ensure you download those too:   

```bash
git clone --recurse-submodules git@github.com:3scale/system system-fresh
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


#### Development Environment Setup 

//TODO: Coming soon...