# Setup Oracle

## Install Oracle Instant Client

1. Go to [the official Oracle Instant Client Downloads site](https://www.oracle.com/database/technologies/instant-client/downloads.html) and download the following **.rpm** packages for your operative system:

  - Basic
  - SQL Plus
  - SDK

2. Create a folder in `/opt/oracle` if it does not exist yet (with `mkdir -p /opt/oracle`) and save these packages there.

3. Install the dependency `libaio1` and the package `alien`.
In Ubuntu that is done with `sudo apt-get install libaio1 alien`.

4. Go to `/opt/oracle` through the terminal (with `cd /opt/oracle`) and use **alien** to convert all those **.rpm** packages to **.deb** (with `sudo alien --to-deb --scripts *.rpm`).

5. Execute all those `.deb` packages with `sudo dpkg -i *.deb`.

6. Execute the following lines and also add them at the end of `~/.profile`. Replace 'X' for the version of the package that you have just installed.

```
export ORACLE_HOME=/usr/lib/oracle/X/client64
export PATH=$PATH:$ORACLE_HOME/bin
export OCI_LIB_DIR=$ORACLE_HOME/lib
export OCI_INC_DIR=/usr/include/oracle/X/client64
```

## Run Oracle Server from Docker

### Prerequisites

You need to have Docker installed and running. You also need to be able to [run containers as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/).

### Steps

1. From this repository, do `make oracle-database` and wait to see *DATABASE IS READY TO USE!*.

2. Finally initialize the database with some seed data by running: `DATABASE_URL="oracle-enhanced://rails:railspass@127.0.0.1:1521/systempdb" ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG=AMERICAN_AMERICA.UTF8 USER_PASSWORD=123456 MASTER_PASSWORD=123456 MASTER_ACCESS_TOKEN=token bundle exec rake db:drop db:create db:setup`
