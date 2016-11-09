docker-moodle
=============

A Dockerfile that installs and runs the latest Moodle 3.1 stable, with external MySQL Database and automatic installation with a default predefined administrator user.

## Installation

```
git clone https://github.com/ellakcy/docker-moodle.git
cd docker-moodle
docker build -t moodle .
```

## Usage

To spawn a new instance of Moodle:

```
docker run -d --name DB -p 3306:3306 -e MYSQL_DATABASE=moodle -e MYSQL_ROOT_PASSWORD=moodle -e MYSQL_USER=moodle -e MYSQL_PASSWORD=moodle mysql
docker run -d -P --name moodle --link DB:DB -e MOODLE_URL=http://0.0.0.0:8080 -p 8080:80 jhardison/moodle
```

Also you can use the following extra enviromental variables (using `-e` option on `docker run` command):

Variable Name | Default value | Description
---- | ------ | ------
**MOODLE_URL** | http://0.0.0.0 | The url of the site that moodle is setup
**MOODLE_ADMIN** | *admin* | The default administrator's username
**MOODLE_ADMIN_PASSWORD** | *Admin~1234* | The administrator's default password. *PLEASE DO CHANGE ON PRODUCTION*
**MOODLE_ADMIN_EMAIL** | *admin@example.com* | Administrator's default email.

You can visit the following URL in a browser to get started:

```
http://0.0.0.0:8080

```
Also you can use the following volumes:

* **/var/moodledata** In order to get all the stored  data.

## Caveats
The following aren't handled, considered, or need work:
* moodle cronjob (should be called from cron container)
* log handling (stdout?)
* email (does it even send?)

## Credits

This is a fork of JmHardison  (https://github.com/jmhardison/docker-moodle)'s Dockerfile.

