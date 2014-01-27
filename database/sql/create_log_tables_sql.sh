#!/bin/bash
# -------------------------------------------
# create_log_tables_sql.sh
#
# Create the SQL that is used to create the
# log tables.
# 
# Usage:
#   ./create_log_tables_sql.sh >create_log_tables.sql
# 
# Then in the database:
#   source create_log_tables.sql
# -------------------------------------------

excludepat='doh\|session'

tbls=$(grep "CREATE TABLE" create_tables.sql |grep -v $excludepat |sed -e 's/CREATE TABLE IF NOT EXISTS `//' |sed -e 's/` (//'|tr '\n' " ")

for t in $tbls
do
  lt=${t}Log
  echo "-- Creating $lt"
  echo "CREATE TABLE $lt LIKE $t;"
  echo "ALTER TABLE $lt ADD COLUMN op CHAR(1) DEFAULT '';"
  echo "ALTER TABLE $lt ADD COLUMN replacedAt DATETIME NOT NULL;"
  echo "ALTER TABLE $lt MODIFY COLUMN id INT DEFAULT 0;"
  echo "ALTER TABLE $lt DROP PRIMARY KEY;"
  echo "ALTER TABLE $lt ADD PRIMARY KEY (id, replacedAt);"
  echo "--"
done

