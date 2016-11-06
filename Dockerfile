# Dockerfile for moodle instance.
# Forked from Jonathan Hardison's <jmh@jonathanhardison.com> docker version. https://github.com/jmhardison/docker-moodle

FROM  php:7.0-apache
MAINTAINER Dimitrios Desyllas <ddesyllas@freemail.gr>
#Original Maintainer Jon Auer <jda@coldshore.com>

VOLUME ["/var/moodledata"]
EXPOSE 80

# Keep upstart from complaining
# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -sf /bin/true /sbin/initctl

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Database info
ENV MOODLE_URL http://0.0.0.0
ENV MOODLE_ADMIN admin
ENV MOODLE_ADMIN_PASSWORD Admin~1234
ENV MOODLE_ADMIN_EMAIL admin@example.com

ADD ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


RUN echo "Installing php and external tools"
RUN apt-get update && \
	apt-get -f -y install pwgen git unzip wget libxmlrpc-c++8-dev libxml2-dev libpng-dev libicu-dev libmcrypt-dev

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install zip
RUN docker-php-ext-install xml
RUN docker-php-ext-install intl
RUN docker-php-ext-install soap
RUN docker-php-ext-install mcrypt

RUN	echo "Installing moodle" && \
		rm -rf /var/www/html/index.html && \
		mkdir /tmp/moodle && \
		git clone -b MOODLE_31_STABLE git://git.moodle.org/moodle.git --depth=1 /tmp/moodle  && \
		mv /tmp/moodle/* /var/www/html/

COPY moodle-config.php /var/www/html/config.php


RUN echo "Fixing Permissions" && \
 		chown -R www-data:www-data /var/www/html && \
		find /var/www/html -iname "*.php" | xargs chmod +x

# Cleanup
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD "apache -D FOREGROUND"
