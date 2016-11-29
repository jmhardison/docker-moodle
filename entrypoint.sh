#!/bin/bash

echo "Installing moodle"

echo "Fixing files and permissions"

chown -R www-data:www-data /var/www/html
find /var/www/html -iname "*.php" | xargs chmod +x

echo "placeholder" > /var/moodledata/placeholder
chown -R www-data:www-data /var/moodledata
chmod 777 /var/moodledata

echo "Setting up database"
: ${MOODLE_DB_TYPE:='mysqli'}

if [ "$MOODLE_DB_TYPE" = "mysqli" ] || [ "$MOODLE_DB_TYPE" = "mariadb" ]; then

: ${MOODLE_DB_HOST:=$DB_PORT_3306_TCP_ADDR}
: ${MOODLE_DB_PORT:=${DB_PORT_3306_TCP_PORT}}

  echo "Waiting for mysql to start at ${MOODLE_DB_HOST} using port ${MOODLE_DB_PORT}..."
  while ! mysqladmin ping -h"$MOODLE_DB_HOST" -P $MOODLE_DB_PORT --silent; do
      echo "Connecting to ${MOODLE_DB_HOST} Failed"
      sleep 1
  done

  echo "Setting up the database connection info"
: ${MOODLE_DB_USER:=${DB_ENV_MYSQL_USER:-root}}
: ${MOODLE_DB_NAME:=${DB_ENV_MYSQL_DATABASE:-'moodle'}}

  if [ "$MOODLE_DB_USER" = 'root' ]; then
: ${MOODLE_DB_PASSWORD:=$DB_ENV_MYSQL_ROOT_PASSWORD}
  else
: ${MOODLE_DB_PASSWORD:=$DB_ENV_MYSQL_PASSWORD}
  fi

elif [ "$MOODLE_DB_TYPE" = "pgsql" ]; then

: ${MOODLE_DB_HOST:=$DB_PORT_5432_TCP_ADDR}
: ${MOODLE_DB_PORT:=${DB_PORT_5432_TCP_PORT}}

  echo "Waiting for postgresql to start at ${MOODLE_DB_HOST} using port ${MOODLE_DB_PORT}..."

  while ! pg_isready -h ${MOODLE_DB_HOST} -p ${MOODLE_DB_PORT} > /dev/null 2> /dev/null; do
    echo "Connecting to ${MOODLE_DB_HOST} Failed"
    sleep 1
  done

  echo "Setting up the database connection info"

: ${MOODLE_DB_NAME:=${DB_ENV_POSTGRES_DB:-'moodle'}}
: ${MOODLE_DB_USER:=${DB_ENV_POSTGRES_USER}}
: ${MOODLE_DB_PASSWORD:=$DB_ENV_POSTGRES_PASSWORD}

if [ -z "$MOODLE_DB_PASSWORD" ]; then
  echo >&2 'error: missing required MOODLE_DB_PASSWORD environment variable'
  echo >&2 '  Did you forget to -e MOODLE_DB_PASSWORD=... ?'
  echo >&2
  exit 1
fi

else
  echo >&2 "This database type is not supported"
  echo >&2 "Did you forget to -e MOODLE_DB_TYPE='mysqli' ^OR^ -e MOODLE_DB_TYPE='mariadb' ^OR^ -e MOODLE_DB_TYPE='pgsql' ?"
  exit 1
fi


# if [ -z "$MOODLE_DB_PASSWORD" ]; then
#   echo >&2 'error: missing required MOODLE_DB_PASSWORD environment variable'
#   echo >&2 '  Did you forget to -e MOODLE_DB_PASSWORD=... ?'
#   echo >&2
#   exit 1
# fi

echo "Installing moodle"
php /var/www/html/admin/cli/install_database.php \
          --adminemail=${MOODLE_ADMIN_EMAIL} \
          --adminuser=${MOODLE_ADMIN} \
          --adminpass=${MOODLE_ADMIN_PASSWORD} \
          --agree-license

exec "$@"
