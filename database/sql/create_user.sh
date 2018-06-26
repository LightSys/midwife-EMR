#!/bin/bash
# Create a user in the database with rights to the specified database.

read -p "Enter database name: " db
read -p "Enter user name: " user
read -p "Enter user password: " pw

function usage() {
  echo "Enter the database name, username, and password for this to work."
}

if [ "$db" = "" ]
then
  usage
  exit 1
fi
if [ "$user" = "" ]
then
  usage
  exit 1
fi
if [ "$pw" = "" ]
then
  usage
  exit 1
fi

sql1="GRANT ALTER, CREATE, CREATE VIEW, DELETE, DROP, INDEX, INSERT, SELECT, SHOW VIEW, UPDATE ON \`${db}\`.* TO \`${user}\`@\`localhost\` IDENTIFIED BY '${pw}'"
sql2="FLUSH PRIVILEGES"

echo "Enter the MySQL root password at the next prompt."
mysql -uroot -p -e "$sql1; $sql2"

