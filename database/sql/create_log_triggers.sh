#!/bin/bash
# -------------------------------------------
# create_log_triggers.sh
#
# Creates the SQL that creates the triggers
# for all of the log tables in order to
# track all changes to the relevant database
# tables.
# -------------------------------------------

if [ $# -ne 2 ]
then
  echo "Usage: $0 username database"
  exit 1
fi

user=$1
db=$2
read -p "Enter the database password for user ${user}: " pass

function run {
  # TODO: fix security issue with password on the command line.
  localsql=$@
  result=$(mysql -BN -h localhost -u $user -p$pass -e "$localsql" $db)
}

function get_columns_sql {
  tbl=$1
  sql="SELECT column_name FROM information_schema.columns WHERE table_name = '$logTbl' AND table_schema = '$db';"
}

function get_tables_sql {
 sql="SELECT table_name FROM information_schema.tables WHERE table_name LIKE '%Log' AND table_schema = '$db';" 
}

get_tables_sql
run $sql
tables=$result

for logTbl in $tables
do
  tbl=$(echo $logTbl|sed -e s/Log//)
  get_columns_sql $logTbl
  run $sql
  columns=$result
  echo "Table: $tbl ===================================="
  echo Columns for $logTbl are
  echo $columns
  echo " "

done

exit

logTbl=patientLog
get_columns_sql $logTbl
run $sql
columns=$result
echo Columns for $logTbl are
echo $columns

logTbl=pregnancyLog
get_columns_sql $logTbl
run $sql
columns=$result
echo Columns for $logTbl are
echo $columns



