# Initializing the Database

Use `shmig` to create the database schema and load a default set of configuration data.

- https://github.com/mbucc/shmig

- Create a shmig.conf file in the top level directory with the following contents adjusted per your requirements.

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
