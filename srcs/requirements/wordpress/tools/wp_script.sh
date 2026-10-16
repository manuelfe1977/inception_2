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


echo "Esperando conexión con MariaDB..."
until mariadb-admin ping -h"mariadb" -u"$SQL_USER" -p"$SQL_PASSWORD" --silent; do
    sleep 2
done
echo "Conexión con MariaDB establecida."

# 3. Moverse al directorio web del contenedor
cd /var/www/wordpress

# 4. Descargar WordPress solo si no existe wp-config.php previo
if [ ! -f "wp-config.php" ]; then
    echo "Descargando WordPress core..."
    wp core download --allow-root

    echo "Creando archivo wp-config.php..."
    wp config create \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$SQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root

    echo "Instalando WordPress..."
    wp core install \
        --url="https://${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creando usuario secundario exigido por el subject..."
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role="author" \
        --allow-root

    # Asegurar permisos correctos para que Nginx y PHP-FPM puedan leer/escribir
    chown -R www-data:www-data /var/www/wordpress
    chmod -R 755 /var/www/wordpress
    echo "Instalación de WordPress finalizada correctamente."
else
    echo "WordPress ya se encuentra instalado. Omitiendo configuración inicial."
fi

# 5. Asegurar el directorio de ejecución para PHP-FPM y levantar el servicio en primer plano
mkdir -p /run/php

# Detectar la versión de PHP instalada y ejecutar en primer plano (-F)
PHP_BIN=$(find /usr/sbin -name "php-fpm*" | head -n 1)

echo "Iniciando servicio PHP-FPM ($PHP_BIN)..."
exec "$PHP_BIN" -F
