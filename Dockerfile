FROM debian:10

RUN apt-get update && apt-get upgrade -y && \
apt-get -y install php-fpm

COPY . /var/www/html

WORKDIR /var/www/html

CMD ["php7.3", "./index.php"]
