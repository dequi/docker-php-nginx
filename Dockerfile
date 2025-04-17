ARG ALPINE_VERSION=3.21
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="Tim de Pater <code@trafex.nl>"
LABEL Description="Lightweight container with Nginx 1.26 & PHP 8.4 based on Alpine Linux."
# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
  curl \
  nginx \
  php84 \
#  php84-apache2 \
  php84-bcmath \
  php84-bz2 \
  php84-calendar \
  php84-cgi \
  php84-common \
  php84-ctype \
  php84-curl \
  php84-dba \
  php84-dbg \
  php84-dev \
  php84-doc \
  php84-dom \
  php84-embed \
  php84-enchant \
  php84-exif \
  php84-ffi \
  php84-fileinfo \
  php84-fpm \
  php84-ftp \
  php84-gd \
  php84-gettext \
  php84-gmp \
  php84-iconv \
  php84-intl \
  php84-ldap \
  php84-litespeed \
  php84-mbstring \
  php84-mysqli \
  php84-mysqlnd \
  php84-odbc \
  php84-opcache \
  php84-openssl \
  php84-pcntl \
  php84-pdo \
  php84-pdo_dblib \
  php84-pdo_mysql \
  php84-pdo_odbc \
  php84-pdo_pgsql \
  php84-pdo_sqlite \
  php84-pear \
  php84-pgsql \
  php84-phar \
  php84-phpdbg \
  php84-posix \
  php84-session \
  php84-shmop \
  php84-simplexml \
  php84-snmp \
  php84-soap \
  php84-sockets \
  php84-sodium \
  php84-sqlite3 \
  php84-sysvmsg \
  php84-sysvsem \
  php84-sysvshm \
  php84-tidy \
  php84-tokenizer \
  php84-xml \
  php84-xmlreader \
  php84-xmlwriter \
  php84-xsl \
  php84-zip \
  supervisor

RUN ln -s /usr/bin/php84 /usr/bin/php

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
ENV PHP_INI_DIR /etc/php84
COPY config/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY config/php.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody:nobody /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping || exit 1
