#!/bin/bash

echo "Fixing files and permissions"
echo "placeholder" > /var/moodledata/placeholder
chown -R www-data:www-data /var/moodledata
chmod 777 /var/moodledata

chown -R www-data:www-data /var/www/html
find /var/www/html -iname "*.php" | xargs chmod +x

echo "Installing moodle"
sleep 1 && php /var/www/html/admin/cli/install_database.php  --adminuser=${MOODLE_ADMIN} --adminpass=${MOODLE_ADMIN_PASSWORD} --agree-license

exec "$@"
