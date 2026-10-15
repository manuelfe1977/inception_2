#!/bin/bash

get_secret() {
    local file_var_name="${1}_FILE"
    if [ -n "${!file_var_name}" ] && [ -f "${!file_var_name}" ]; then
        cat "${!file_var_name}"
    else
        echo "${!1}"
    fi
}

SQL_PASSWORD=$(get_secret "SQL_PASSWORD")
WP_ADMIN_PASSWORD=$(get_secret "WP_ADMIN_PASSWORD")
WP_USER_PASSWORD=$(get_secret "WP_USER_PASSWORD")


sleep 10

cd /var/www/wordpress

while ! mysqladmin ping -h"mariadb" --silent; do
    sleep 1
done

if [ ! -f "wp-config.php" ]; then
	wp core download --allow-root

	wp config create --dbname=$SQL_DATABASE --dbuser=$SQL_USER --dbpass=$SQL_PASSWORD --dbhost=mariadb:3306 --allow-root

	wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSORD --admin_email=$WP_ADMIN_EMAIL --allow-root

	wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD --role=author --allow-root
fi

mkdir -p /run/php

exec /usr/sbin/php-fpm7.4 -F
