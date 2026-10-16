#!/bin/bash

get_secret() {
    local file_var_name="${1}_FILE"
    # Si la variable _FILE existe y apunta a un archivo real, léelo
    if [ -n "${!file_var_name}" ] && [ -f "${!file_var_name}" ]; then
        cat "${!file_var_name}"
    else
        # Fallback por si acaso estuviera en texto plano normal
        echo "${!1}"
    fi
}

SQL_PASSWORD_FILE=$(get_secret "SQL_PASSWORD")
SQL_ROOT_PASSWORD_FILE=$(get_secret "SQL_ROOT_PASSWORD")

if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
	mysqld_safe --skip-networking &

	until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

	mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
	mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD_FILE}';"
	mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD_FILE}';"
	mysql -e "FLUSH PRIVILEGES"

	mysqladmin -u root -p${SQL_ROOT_PASSWORD_FILE} shutdown
fi

exec "$@"
