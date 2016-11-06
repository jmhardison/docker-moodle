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
		apt-get -f -y install pwgen aspell unzip wget libxmlrpc-c++8-dev libxml2-dev libpng-dev libicu-dev libmcrypt-dev &&\
		docker-php-ext-install pdo_mysql && \
 		docker-php-ext-install xmlrpc && \
		docker-php-ext-install mbstring && \
		docker-php-ext-install zip && \
		docker-php-ext-install xml && \
		docker-php-ext-install intl && \
 		docker-php-ext-install soap && \
 		docker-php-ext-install mcrypt && \
		echo "Installing moodle" && \
		wget https://download.moodle.org/download.php/direct/stable31/moodle-latest-31.tgz -O /tmp/moodle-latest-31.tgz  && \
		rm -rf /var/www/html/index.html && \
		tar -xvf /tmp/moodle-latest-31.tgz -C /tmp && \
		mv /tmp/moodle/* /var/www/html/

COPY moodle-config.php /var/www/html/config.php


# Cleanup
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD /usr/sbin/apache2ctl -D FOREGROUND
