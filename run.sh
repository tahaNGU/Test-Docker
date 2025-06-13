#!/bin/bash

shutdown() {
  echo "Stopping nginx and php-fpm..."
  pkill -TERM php-fpm
  pkill -TERM nginx
  exit 0
}

trap shutdown SIGTERM SIGINT

touch /var/www/html/storage/logs/laravel.log &&
chown -R nginx:nginx /var/www/html/storage &&
chmod -R 0777 /var/www/html/storage &&

rm -rf /var/www/html/vendor /ar/www/html/composer.lock &&
composer install --ignore-platform-reqs &&

php artisan migrate &&
# php artisan db:seed &&
php artisan key:generate &&
php artisan storage:link &&
php artisan config:cache &&
php artisan cache:clear &&
php artisan config:clear &&

echo "Starting nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!
echo "Starting php-fpm..."
php-fpm83 --nodaemonize &
PHP_FPM_PID=$!

echo "Tailing logs..."
tail -f /var/www/html/storage/logs/laravel.log &

while true; do
  if ! kill -0 $NGINX_PID 2>/dev/null; then
    echo "nginx has stopped!"
    break
  fi

  if ! kill -0 $PHP_FPM_PID 2>/dev/null; then
    echo "php-fpm has stopped!"
    break
  fi

  sleep 1
done

echo "One of the processes has stopped. Exiting to restart container..."
shutdown
