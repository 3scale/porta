## Prerequisites on Fedora 35+

### Install Oracle Instant Client

Go to [the official Oracle Instant Client Downloads site](https://www.oracle.com/database/technologies/instant-client/downloads.html) and install basic and SDK RPMs like this:

```
sudo dnf install https://download.oracle.com/otn_software/linux/instantclient/1918000/oracle-instantclient19.18-basic-19.18.0.0.0-2.x86_64.rpm https://download.oracle.com/otn_software/linux/instantclient/1918000/oracle-instantclient19.18-devel-19.18.0.0.0-2.x86_64.rpm
```

If you wish, you can also install SQLPLus client from same location as well.

### Setup Podman with user namespaces

On recent Fedora versions, new users already have that setup.

```sh
dnf install -y podman-docker
sudoedit /etc/subuid # add line: myusername:10000:54321
sudoedit /etc/subgid # add line: myusername:10000:54330
```

## Prerequisites on other Linux and probably MAC

### Install Oracle Instant Client using the script

1. Run the script with sudo
```shell
$ sudo ./script/oracle/install-instantclient-packages.sh
```

2. Add following ENV variables to your system (`~/.profile` or `~/.zshrc`)

```shell
LD_LIBRARY_PATH="/opt/oracle/instantclient/:$LD_LIBRARY_PATH"
ORACLE_HOME=/opt/oracle/instantclient/
```

### Install Oracle Instant Client via RPM

1. Go to [the official Oracle Instant Client Downloads site](https://www.oracle.com/database/technologies/instant-client/downloads.html) and download the following **.rpm** packages for your operative system:

  - Basic
  - SQL Plus
  - SDK

On Fedora or a Red Hat based distro, you can just install the RPMs. Instructions for Debian based systems follow.

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

### Setup Docker (but preferably use podman)

You need to have Docker installed and running. You also need to be able to [run containers as a non-root user](https://docs.docker.com/install/linux/linux-postinstall/).

## Run Oracle server

1. From this repository, do `make oracle-database` and wait **_a little_**, or check `podman logs -f oracle-database` to see *DATABASE IS READY TO USE!* message.


      - This will create an Oracle database container that has a "rails" user to use for development purposes.

      - If you run oracle in another way, then you can create a development user manually like this:
        ```
        docker exec -it oracle-database sqlplus system/threescalepass@127.0.0.1:1521/systempdb
        ```
        ```sql
        CREATE USER rails IDENTIFIED BY railspass;
        GRANT unlimited tablespace TO rails;
        GRANT create session TO rails;
        GRANT create table TO rails;
        GRANT create view TO rails;
        GRANT create sequence TO rails;
        GRANT create trigger TO rails;
        GRANT create procedure TO rails;
        ```

2. Finally initialize the database with some seed data by running (omit `ORACLE_SYSTEM_PASSWORD` if you have already granted the necessary permissions to the user)
    ```
    DATABASE_URL="oracle-enhanced://rails:railspass@127.0.0.1:1521/systempdb" ORACLE_SYSTEM_PASSWORD=threescalepass NLS_LANG=AMERICAN_AMERICA.UTF8 USER_PASSWORD=123456 MASTER_PASSWORD=123456 MASTER_ACCESS_TOKEN=token bundle exec rake db:drop db:create db:setup
    ```

## Troubleshooting

### ORA-12637: Packet receive failed

Add `DISABLE_OOB=ON` to `sqlnet.ora` ([github issue](https://github.com/oracle/docker-images/issues/1352)). For installation from archive that would be

```shell
echo "DISABLE_OOB=ON" >> /opt/oracle/instantclient/network/admin/sqlnet.ora
```

For RPM installation (update version `21` with whatever you installed locally).
```shell
echo "DISABLE_OOB=ON" >> /usr/lib/oracle/21/client64/lib/network/admin/sqlnet.ora
```

For IntelliJ/RubyMine, go to Database -> Database Source properties -> Drivers -> Oracle -> Advanced -> oracle.net.disableOob -> true
