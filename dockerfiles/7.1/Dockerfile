FROM php:7.1-fpm
# https://github.com/johnpbloch/phpfpm-images/blob/master/images/7.1/Dockerfile

COPY ./build.sh /var/www/build.sh

RUN chmod +x /var/www/build.sh && sh /var/www/build.sh

CMD ["php-fpm"]

EXPOSE 9000
