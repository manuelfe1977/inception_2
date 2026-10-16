FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/mariadb_script.sh /usr/local/bin/mariadb_script.sh
RUN chmod +x /usr/local/bin/mariadb_script.sh

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

EXPOSE 3306

ENTRYPOINT [ "mariadb_script.sh"]

CMD [ "mysqld", "--bind-address=0.0.0.0"]
