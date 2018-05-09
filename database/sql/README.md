# Initializing the Database

## How to Create the Schema

Use `shmig` to create the database schema and load a default set of
configuration data.

- https://github.com/mbucc/shmig

- Create a shmig.conf file in the top level directory with the following
  contents adjusted per your requirements.

```
TYPE="mysql"
HOST="localhost"
DATABASE="midwifeemr"
LOGIN="root"
```

- From the top-level, run shmig

```
shmig -A migrate
```

## How to recreate the triggers

```
cd database/sql
./create_log_triggers.sh databaseUser databaseName > create_log_triggers.sql
```

Note: usually we add the file that we output this script into to the .gitignore
file. In any case, there is no need to add it to version control.

Then add the triggers required into a new shmig migration file and delete the
output file as a result of running the script.
