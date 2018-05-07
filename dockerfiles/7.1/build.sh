#!/bin/bash

apt-get update

apt-get install -y \
        libgraphicsmagick1-dev \
        graphicsmagick \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        libz-dev \
        less \
        mysql-client \
        libmemcached11 \
        libmemcachedutil2 \
        libmemcached-dev

docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo \
        pdo_mysql \
        sockets \
        zip \

docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

docker-php-ext-install -j$(nproc) gd

pecl install xdebug

pecl install memcached

pecl install gmagick-2.0.4RC1

docker-php-ext-enable xdebug memcached

apt-get remove -y build-essential libz-dev libmemcached-dev

apt-get autoremove -y

apt-get clean

curl https://getcomposer.org/download/$(curl -LSs https://api.github.com/repos/composer/composer/releases/latest | grep 'tag_name' | sed -e 's/.*: "//;s/".*//')/composer.phar > composer.phar \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

curl -L https://phar.phpunit.de/phpunit.phar > /tmp/phpunit.phar \
	&& chmod +x /tmp/phpunit.phar \
	&& mv /tmp/phpunit.phar /usr/local/bin/phpunit

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

apt-get update && apt-get install -y \
	git \
	subversion \
	wget \
	libxml2-dev \
	ssmtp \
	nodejs \
	npm \
	ruby-full

apt-get update
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 || gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
usermod -a -G rvm 'root' && usermod -a -G rvm 'www-data'

gem install sass

gem install compass

npm install -g grunt-cli

npm install -g bower

docker-php-ext-install soap

echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf
