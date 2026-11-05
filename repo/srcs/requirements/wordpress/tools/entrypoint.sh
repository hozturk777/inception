#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep '^WP_ADMIN_PASSWORD=' /run/secrets/credentials | cut -d= -f2-)
WP_USER_PASSWORD=$(grep '^WP_USER_PASSWORD=' /run/secrets/credentials | cut -d= -f2-)

case "$(echo "$WP_ADMIN_USER" | tr '[:upper:]' '[:lower:]')" in
    *admin*)
        echo "Error: WP_ADMIN_USER must not contain 'admin'" >&2
        exit 1
        ;;
esac

cd /var/www/html

if [ ! -f wp-load.php ]; then
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost=mariadb:3306
fi

if ! wp core is-installed --allow-root 2> /dev/null; then
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
fi

if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
    wp user create "$WP_USER" "$WP_USER_EMAIL" --allow-root \
        --role=author \
        --user_pass="$WP_USER_PASSWORD"
fi

chown -R www-data:www-data /var/www/html

exec "$@"
