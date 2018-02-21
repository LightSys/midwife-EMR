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

# Don't create log tables for these tables.
excludepat='doh\|sessions\|event\|eventType\|priority\|riskCode\|customFieldType\|roFieldsByRole'

# Certain tables have unique constraints which do not allow proper logging
# when they exist in the log tables. We have a hard-coded list of the 
# constraints that need to be removed.
uniq_name_tbls='roleLog vaccinationTypeLog medicationTypeLog labSuiteLog labTestLog selectDataLog'
uniq_username_tbls='userLog'
uniq_labTestId_tbls='labTestValueLog'
uniq_abbrev_tbls='labTestLog'
uniq_pregnancy_tbls='scheduleLog riskLog'
uniq_custom_field_tbls='customFieldLog'
uniq_sortOrder_tbls='medicationTypeLog vaccinationTypeLog'
uniq_kvKey_tbls='keyValueLog'
uniq_laborId_tbls='laborStage1Log laborStage2Log laborStage3Log babyLog membraneLog'
uniq_babyId_tbls='apgarLog newbornExamLog babyMedicationLog babyVaccinationLog'

# Get the list of tables from the creation script.
tbls=$(grep "CREATE TABLE" create_tables.sql |grep -v $excludepat |sed -e 's/CREATE TABLE IF NOT EXISTS `//' |sed -e 's/` (//'|tr '\n' " ")

for t in $tbls
do
  lt=${t}Log
  echo "-- Creating $lt"
  echo "SELECT '$lt' AS Creating FROM DUAL;"
  echo "CREATE TABLE $lt LIKE $t;"
  echo "ALTER TABLE $lt ADD COLUMN op CHAR(1) DEFAULT '';"
  echo "ALTER TABLE $lt ADD COLUMN replacedAt DATETIME NOT NULL;"
  echo "ALTER TABLE $lt MODIFY COLUMN id INT DEFAULT 0;"
  echo "ALTER TABLE $lt DROP PRIMARY KEY;"
  echo "ALTER TABLE $lt ADD PRIMARY KEY (id, replacedAt);"
  for ut in $uniq_name_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY name;"
    fi
  done
  for ut in $uniq_username_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY username;"
    fi
  done
  for ut in $uniq_labTestId_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY labTest_id;"
    fi
  done
  for ut in $uniq_abbrev_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY abbrev;"
    fi
  done
  for ut in $uniq_pregnancy_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY pregnancy_id;"
    fi
  done
  for ut in $uniq_custom_field_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY customFieldType_id;"
    fi
  done
  for ut in $uniq_sortOrder_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY sortOrder;"
    fi
  done
  for ut in $uniq_kvKey_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY kvKey;"
    fi
  done
  for ut in $uniq_laborId_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY labor_id;"
    fi
  done
  for ut in $uniq_babyId_tbls
  do
    if [ $ut = $lt ]
    then
      echo "ALTER TABLE $lt DROP KEY baby_id;"
    fi
  done
  echo "--"
done

