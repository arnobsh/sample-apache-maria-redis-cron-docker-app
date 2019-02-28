FROM php:7-apache
MAINTAINER Arnob Saha <arnobsh@gmail.com>

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
RUN apt-get update \
    && apt-get install -y curl wget git zip unzip zlib1g-dev libpng-dev \
       gnupg2 libldap2-dev ssl-cert libzip-dev libssl-dev \
    && apt-get autoremove \
    && apt-get clean \
    && yes '' | pecl install -f redis \
       && rm -rf /tmp/pear \
       && docker-php-ext-enable redis \
    && a2enmod rewrite ssl \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install gd zip

# Install composer

RUN cd ~ \
    && wget https://getcomposer.org/installer \
    && php installer \
    && rm installer \
    && mkdir bin \
    && mv composer.phar bin/composer \
    && chmod u+x bin/composer

# Add our script files so they can be found
ENV PATH /root/bin:~/.composer/vendor/bin:$PATH

# Manually set up the apache environment variables
RUN a2enmod vhost_alias http2 headers rewrite ssl

# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Update Linux app database and install Linux dev tools
RUN apt-get update \
    && apt-get install -y net-tools curl wget zip unzip zlib1g-dev \
       libpng-dev joe gnupg2 libldap2-dev inetutils-ping
	   
# Setup PHP developer tools
RUN docker-php-ext-install gd zip ldap gettext \
    && composer global require phpunit/phpunit \
       phing/phing \
       sebastian/phpcpd \
       phploc/phploc \
       phpmd/phpmd \
       squizlabs/php_codesniffer
	   
# Setup Redis server
RUN apt-get install -y redis-server

## Setup MariaDB

RUN apt-get install -y mariadb-server mariadb-client \
    && docker-php-ext-install pdo pdo_mysql mysqli \
    && /bin/bash -c "/usr/bin/mysqld_safe &" \
        && sleep 5 \
        && mysql -u root -ppassword -e "CREATE USER 'root'@'%' IDENTIFIED BY 'password';" \
        && mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' REQUIRE NONE WITH GRANT OPTION MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;" \
        && mysql -u root -ppassword -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;" \
        && sed -i '/bind-address/c\bind-address\t\t= 0.0.0.0' /etc/mysql/my.cnf \
        && sed -Ei "s/bind-address.*/bind-address=0.0.0.0/g" /etc/mysql/mariadb.conf.d/50-server.cnf
		
# Setup at and cron
RUN apt-get install -y cron  at
# CRON Config
ADD /crontab /etc/

# Setup logs to behave like Linux/Unix
RUN rm -f /var/log/apache2/access.log \
    && rm -f /var/log/apache2/error.log \
    && rm -f /var/log/apache2/other_vhosts_access.log
	
# CLI XDebug
ENV XDEBUG_CONFIG remote_host=host.docker.internal remote_port=9000 remote_autostart=1

ENV MYSQL_HOST localhost
ENV MYSQL_USER root
ENV MYSQL_PWD password



WORKDIR /var/www

EXPOSE 80 443 3000

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND