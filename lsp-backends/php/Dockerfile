FROM registry.digitalocean.com/watheia/theia-server:common

# PHP
ARG PHP_VERSION=7.4

RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get install -y curl php$PHP_VERSION php$PHP_VERSION-cli php$PHP_VERSION-mbstring unzip php$PHP_VERSION-common php$PHP_VERSION-json php-yaml php-xdebug \
    && apt-get remove -y software-properties-common
RUN echo '[XDebug]\n\
    xdebug.remote_enable = 1\n\
    xdebug.remote_autostart = 1' >> /etc/php/$PHP_VERSION/mods-available/xdebug.ini
RUN curl -s -o composer-setup.php https://getcomposer.org/installer \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php
