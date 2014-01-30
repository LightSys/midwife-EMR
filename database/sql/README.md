# Managing the Database

Creating the database manually, creating the schema and loading default data.
This is how to do it until a full database load script is written.

## Creation

ToDo.

## Creation of schema

- From the shell, navigate to the database/sql directory then:

    ./create_log_tables_sql.sh >create_log_tables.sql

- From within MySql (assuming mysql was started from the database/sql
  directory):

    source create_tables.sql
    source create_log_tables.sql

- From the shell again:

    ./create_log_triggers.sh DBUser DBName >create_log_triggers.sql

where DBUser is the database user and DBName is the name of the database.
This will prompt for a password for the database user that you specified.

- From within MySQL again:

    source create_log_triggers.sql


## Loading of default data

- From within MySQL again:

    source load_default_data.sql

Now you can start the application and login as 'admin' with a password of
'admin'.

