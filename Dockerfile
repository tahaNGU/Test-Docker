FROM php:8.3-fpm-alpine

RUN apk --no-cache add nginx php php-gd php-json php-curl php-cli php-fpm openssl libressl-dev php-openssl php-phar php-iconv php-tokenizer php-dom npm php-session php-xmlwriter php-xml php-fileinfo php-zip php-pdo php-mbstring php-ctype php-mysqlnd php-mysqli php-pdo_mysql php-redis php-dom php-simplexml php-xmlreader php-xmlwriter tzdata

ENV TZ=Asia/Tehran
ARG IMAGE_NAME
ARG IMAGE_TAG_TAG

ENV PROJECT_NAME=${IMAGE_NAME}
ENV VERSION=${IMAGE_TAG_TAG}

COPY ./nginx/conf.d/default.conf /etc/nginx/http.d/default.conf


WORKDIR /var/www/html
COPY . /var/www/html

COPY ./php.ini /etc/php83/conf.d/30-custom.ini

RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php83/php-fpm.d/www.conf

EXPOSE 80

CMD ["sh", "-c", "sh /var/www/html/run.sh"]
