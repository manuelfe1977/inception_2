FROM debian:bookworm

RUN apt-get update && apt-get install -y php7.4-fpm php7.4-mysql mariadb-client curl && rm -rf /var/lib/apt/list/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

COPY tools/wp_script.sh /usr/local/bin/wp_script.sh
RUN chmod +x /usr/local/bin/wp_script.sh

WORKDIR /var/www/wordpress

ENTRYPOINT ["wp_script.sh"]
