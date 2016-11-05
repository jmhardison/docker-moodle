# Dockerfile for moodle instance.
# Forked from Jonathan Hardison's <jmh@jonathanhardison.com> docker version. https://github.com/jmhardison/docker-moodle

FROM ubuntu:16.04
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

ADD ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


RUN echo "Installing php and external tools"
RUN apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php \
		php-gd libapache2-mod-php postfix wget supervisor php-pgsql curl libcurl3 \
		libcurl3-dev php-curl php-xmlrpc php-intl php-mysql git-core php-xml php-mbstring php-zip php-soap

RUN echo "Installing moodle"
RUN	rm /var/www/html/index.html && \
    cd /tmp && \
	  git clone -b MOODLE_31_STABLE git://git.moodle.org/moodle.git --depth=1 && \
	  mv /tmp/moodle/* /var/www/html/

COPY moodle-config.php /var/www/html/config.php

# Enable SSL, moodle requires it
# if using proxy, don't need actually secure connection
#RUN a2enmod ssl && a2ensite default-ssl

# Cleanup
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD source /etc/apache2/envvars && \
 		apache2 -D FOREGROUND
