FROM debian:10

RUN apt-get update && apt-get upgrade -y && \
apt-get -y install php-fpm

WORKDIR /var/www

CMD ["php7.3"]

