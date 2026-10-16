FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Configurar PHP-FPM para escuchar en el puerto 9000 (en vez de socket UNIX)
RUN sed -i 's|listen = /run/php/php.*-fpm.sock|listen = 9000|g' /etc/php/*/fpm/pool.d/www.conf

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Crear el directorio destino
RUN mkdir -p /var/www/wordpress /run/php

# Copiar el script de inicio
COPY tools/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

WORKDIR /var/www/wordpress

ENTRYPOINT ["/usr/local/bin/auto_config.sh"]
