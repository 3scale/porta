#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

echo "::::::::::::::::: MAX_STRING_SIZE = EXTENDED :::::::::::::::::"
sqlplus / as sysdba << EOF
  ALTER SYSTEM SET max_string_size=extended SCOPE=SPFILE;
  ALTER SYSTEM SET compatible='12.2.0.1' SCOPE=SPFILE;
  ALTER SYSTEM SET archive_lag_target=0 SCOPE=BOTH;
  ALTER SESSION SET CONTAINER=systempdb;
  ALTER PROFILE "DEFAULT" LIMIT PASSWORD_VERIFY_FUNCTION NULL;
  CREATE USER rails IDENTIFIED BY railspass;
  GRANT PDB_DBA TO rails WITH ADMIN OPTION;
  ALTER SESSION SET CONTAINER=CDB\$ROOT;
  SHUTDOWN IMMEDIATE;
  STARTUP UPGRADE;
  ALTER PLUGGABLE DATABASE ALL OPEN UPGRADE;
  EXIT;
EOF

echo "::::::::::::::::: Running utl32k.sql :::::::::::::::::"
cd "$ORACLE_HOME/rdbms/admin/"

"$ORACLE_HOME/perl/bin/perl" catcon.pl -d "$ORACLE_HOME/rdbms/admin" -l /tmp -b utl32k_output utl32k.sql
cd

echo "::::::::::::::::: Restarting container :::::::::::::::::"
sqlplus / as sysdba << EOF
  SHUTDOWN IMMEDIATE;
  STARTUP;
  EXIT;
EOF

echo "::::::::::::::::: Creating other PDBS :::::::::::::::::"

sqlplus / as sysdba << EOF
  ALTER PLUGGABLE DATABASE systempdb OPEN READ ONLY;
  DECLARE
    sql_stmt          VARCHAR2(1000);
    type array_t is varray(2) of varchar2(10);
    array array_t := array_t('test', 'production');

    BEGIN
      FOR i IN 1..array.count LOOP
        sql_stmt :=  'CREATE PLUGGABLE DATABASE systempdb' || array(i) ||
                      q'[ ADMIN USER rails IDENTIFIED BY railspass  FILE_NAME_CONVERT=('/opt/oracle/oradata/threescale/pdbseed',]' ||
                      q'['/opt/oracle/oradata/threescale/systempdb]' || array(i) || q'[')]';
        EXECUTE IMMEDIATE sql_stmt;

    END LOOP;
  END;
  /
  ALTER SESSION SET CONTAINER=systempdbtest;
  ALTER PROFILE "DEFAULT" LIMIT PASSWORD_VERIFY_FUNCTION NULL;
  ALTER SESSION SET CONTAINER=systempdbproduction;
  ALTER PROFILE "DEFAULT" LIMIT PASSWORD_VERIFY_FUNCTION NULL;
  ALTER SESSION SET CONTAINER=CDB\$ROOT;
  ALTER PLUGGABLE DATABASE ALL OPEN READ WRITE;
  ALTER PLUGGABLE DATABASE ALL SAVE STATE;
  EXIT;
EOF
