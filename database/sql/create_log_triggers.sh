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

delimiter='$$'

function run {
  # TODO: fix security issue with password on the command line.
  localsql=$@
  result=$(mysql -BN -h localhost -u $user -p$pass -e "$localsql" $db)
}

function get_columns_sql {
  local tbl=$1
  sql="SELECT column_name FROM information_schema.columns WHERE table_name = '$tbl' AND table_schema = '$db';"
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
  columnsCommas=$(echo $columns|sed -e 's/ /, /g')
  echo " "
  echo "-- ---------------------------------------------------------------"
  echo "-- Trigger: ${tbl}_after_insert"
  echo "-- ---------------------------------------------------------------"

cat <<TRIGGER1
DELIMITER ${delimiter}
DROP TRIGGER IF EXISTS ${tbl}_after_insert;
CREATE TRIGGER ${tbl}_after_insert AFTER INSERT ON ${tbl}
FOR EACH ROW
BEGIN
  INSERT INTO ${logTbl}
  ($columnsCommas)
TRIGGER1

  for col in $columnsCommas
  do
    if [ $col = 'id,' ]
    then
      echo -n "  VALUES (NEW.${col} "
      continue
    fi
    if [ $col = 'op,' ]
    then
      echo -n '"I", '
      continue
    fi
    if [ $col = 'replacedAt' ]
    then
      echo -n "NOW()"
      continue
    fi
    echo -n "NEW.${col} "
  done

cat <<TRIGGER2
);
END;${delimiter}
DELIMITER ; 
TRIGGER2

  echo " "
  echo "-- ---------------------------------------------------------------"
  echo "-- Trigger: ${tbl}_after_update"
  echo "-- ---------------------------------------------------------------"

cat <<TRIGGER3
DELIMITER ${delimiter}
DROP TRIGGER IF EXISTS ${tbl}_after_update;
CREATE TRIGGER ${tbl}_after_update AFTER UPDATE ON ${tbl}
FOR EACH ROW
BEGIN
  INSERT INTO ${logTbl}
  ($columnsCommas)
TRIGGER3

  for col in $columnsCommas
  do
    if [ $col = 'id,' ]
    then
      echo -n "  VALUES (NEW.${col} "
      continue
    fi
    if [ $col = 'op,' ]
    then
      echo -n '"U", '
      continue
    fi
    if [ $col = 'replacedAt' ]
    then
      echo -n "NOW()"
      continue
    fi
    echo -n "NEW.${col} "
  done

cat <<TRIGGER4
);
END;${delimiter}
DELIMITER ; 
TRIGGER4


  echo " "
  echo "-- ---------------------------------------------------------------"
  echo "-- Trigger: ${tbl}_after_delete"
  echo "-- ---------------------------------------------------------------"

cat <<TRIGGER5
DELIMITER ${delimiter}
DROP TRIGGER IF EXISTS ${tbl}_after_delete;
CREATE TRIGGER ${tbl}_after_delete AFTER DELETE ON ${tbl}
FOR EACH ROW
BEGIN
  INSERT INTO ${logTbl}
  ($columnsCommas)
TRIGGER5

  for col in $columnsCommas
  do
    if [ $col = 'id,' ]
    then
      echo -n "  VALUES (OLD.${col} "
      continue
    fi
    if [ $col = 'op,' ]
    then
      echo -n '"D", '
      continue
    fi
    if [ $col = 'replacedAt' ]
    then
      echo -n "NOW()"
      continue
    fi
    echo -n "OLD.${col} "
  done

cat <<TRIGGER6
);
END;${delimiter}
DELIMITER ; 
TRIGGER6
done

