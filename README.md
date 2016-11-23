docker-moodle
=============

A Docker image that installs and runs the latest Moodle 3.1 stable, with external MySQL/Mariadb Database and automatic installation with a default predefined administrator user.

## Installation

```
git clone https://github.com/ellakcy/docker-moodle.git
cd docker-moodle
docker build -t moodle .
```

## Usage

To spawn a new instance of Moodle:

* Using mysql:

```
docker run -d --name DB -e MYSQL_DATABASE=moodle -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_ONETIME_PASSWORD=yes -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql
docker run -d -P --name moodle --link DB:DB -e MOODLE_URL=http://0.0.0.0:8080 -p 8080:80 ellakcy/moodle
```

* Using mariadb:

```
docker run -d --name DB -e MYSQL_DATABASE=moodle -e MYSQL_RANDOM_ROOT_PASSWORD=yes -e MYSQL_ONETIME_PASSWORD=yes -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mariadb
docker run -d -P --name moodle --link DB:DB -e MOODLE_URL=http://0.0.0.0:8080 -e MOODLE_DB_TYPE="mariadb" -p 8080:80 ellakcy/moodle
```

Then you can visit the following URL in a browser to get started:

```
http://0.0.0.0:8080

```

Also you can use the following extra enviromental variables (using `-e` option on `docker run` command):

* For default user:
Variable Name | Default value | Description
---- | ------ | ------
**MOODLE_URL** | http://0.0.0.0 | The url of the site that moodle is setup
**MOODLE_ADMIN** | *admin* | The default administrator's username
**MOODLE_ADMIN_PASSWORD** | *Admin~1234* | The administrator's default password. *PLEASE DO CHANGE ON PRODUCTION*
**MOODLE_ADMIN_EMAIL** | *admin@example.com* | Administrator's default email.

* For database management:
Variable Name | Default value | Description
---- | ------ | ------
**MOODLE_DB_TYPE** | *mysqli* | The type of the database it can be either *mysqli* or *mariadb*
**MOODLE_DB_HOST** | | The url that the database is accessible
**MOODLE_DB_PASSWORD** | | The password for the database
**MOODLE_DB_USER** | | The username of the database
**MOODLE_DB_NAME** | | The database name
**MOODLE_DB_PORT** | | The port that the database is accessible

If no value specified and the the container that runs the current docker image is conencted to another database container then depending the value of `MOODLE_DB_TYPE` it will autodetect the correct parameters.


Also you can use the following volumes:

* **/var/moodledata** In order to get all the stored  data.

## Caveats
The following aren't handled, considered, or need work:
* moodle cronjob (should be called from cron container)
* log handling (stdout?)
* email (does it even send?)

## Credits

This is a fork of JmHardison  (https://github.com/jmhardison/docker-moodle)'s Dockerfile.
