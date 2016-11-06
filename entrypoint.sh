#!/bin/bash

echo "Fixing files and permissions"

chown -R www-data:www-data /var/www/html
find /var/www/html -iname "*.php" | xargs chmod +x

echo "placeholder" > /var/moodledata/placeholder
chown -R www-data:www-data /var/moodledata
chmod 777 /var/moodledata

echo "Installing moodle"

#Loop until sucessfylly installs
sleep 10 && php /var/www/html/admin/cli/install_database.php \
          --adminemail=${MOODLE_ADMIN_EMAIL} \
          --adminuser=${MOODLE_ADMIN} \
           --adminpass=${MOODLE_ADMIN_PASSWORD} \
          --agree-license

exec "$@"
