#!/bin/bash

# Site configuration options
SITE_TITLE='Dev Site'
ADMIN_USER=admin
ADMIN_PASS=password
ADMIN_EMAIL='admin@localhost.com'
# Space-separated list of plugin IDs to install and activate (optional)
PLUGINS='advanced-custom-fields'
WP_PORT=8200

# Set to true to wipe out and reset your wordpress install (on next container rebuild)
WP_RESET=false

echo 'Setting up WordPress'
DEVDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "${DEVDIR}/.." >/dev/null 2>&1 && pwd)"
cd /var/www/html

# Download WordPress core if not present (but preserve wp-content)
if [ ! -f wp-config-sample.php ]; then
	echo 'Downloading WordPress core files...'
	# Create temporary directory for download
	mkdir -p /tmp/wp-download
	cd /tmp/wp-download
	php -d memory_limit=512M /usr/local/bin/wp core download
	# Move WordPress files but preserve our wp-content
	cp -rn * /var/www/html/ 2>/dev/null || true
	# Clean up
	cd /var/www/html
	rm -rf /tmp/wp-download
	# Remove default wp-content and link to the current repository
	sudo rm -rf wp-content && ln -s "${REPO_ROOT}" wp-content
	echo 'WordPress core files downloaded and repository wp-content linked'
else
	echo 'WordPress core files already present'
	if [ "$(readlink -f wp-content 2>/dev/null || true)" != "${REPO_ROOT}" ]; then
		sudo rm -rf wp-content && ln -s "${REPO_ROOT}" wp-content
		echo 'Re-linked wp-content to repository path'
	fi
fi

# Configure Apache for the WordPress port
echo "Configuring Apache for port ${WP_PORT}..."
sudo sed -i '/^Listen /d' /etc/apache2/ports.conf
echo "Listen ${WP_PORT}" | sudo tee /etc/apache2/ports.conf >/dev/null
sudo find /etc/apache2/sites-enabled -maxdepth 1 -type l -name '*.conf' -delete
sudo rm -f /etc/apache2/sites-available/wordpress-*.conf

# Create virtual host for the WordPress port
sudo bash -c "cat > /etc/apache2/sites-available/wordpress-${WP_PORT}.conf << EOT
<VirtualHost *:${WP_PORT}>
	ServerName localhost
	DocumentRoot /var/www/html
	DirectoryIndex index.php

	<Directory /var/www/html>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT"

# Enable only the WordPress site
sudo a2ensite "wordpress-${WP_PORT}" >/dev/null 2>&1
sudo apache2ctl configtest

echo "Apache configured for port ${WP_PORT}"

# Wait for database to be ready
echo 'Waiting for database to be ready...'
for i in {1..10}; do
	if mysql -h localhost -u wp_user -pwp_pass -e 'SELECT 1' >/dev/null 2>&1; then
		echo 'Database is ready!'
		break
	fi
	echo "Database not ready yet, waiting 2 seconds... (attempt $i/10)"
	sleep 2
	if [ "$i" -eq 10 ]; then
		echo 'Database connection timeout - proceeding anyway'
		echo 'Error: Could not connect to database at localhost'
	fi
done

if $WP_RESET; then
	echo 'Resetting WP (WP_RESET is true)'
	if [ -n "$PLUGINS" ]; then
		wp plugin delete $PLUGINS 2>/dev/null || true
	fi
	wp db reset --yes 2>/dev/null || true
	sudo rm -f wp-config.php 2>/dev/null || rm -f wp-config.php 2>/dev/null || true
else
	echo 'Preserving existing WordPress installation (WP_RESET is false)'
fi

if [ ! -f wp-config.php ]; then
	echo 'Configuring'
	wp config create --dbhost='localhost:/run/mysqld/mysqld.sock' --dbname='wordpress' --dbuser='wp_user' --dbpass='wp_pass' --skip-check
	wp core install --url="http://localhost:${WP_PORT}" --title="$SITE_TITLE" --admin_user="$ADMIN_USER" --admin_email="$ADMIN_EMAIL" --admin_password="$ADMIN_PASS" --skip-email
	if [ -n "$PLUGINS" ]; then
		wp plugin install $PLUGINS --activate
	fi

	# Data import
	if [ -d "$DEVDIR/data/" ] && [ "$(ls -A $DEVDIR/data/*.sql 2>/dev/null)" ]; then
		cd "$DEVDIR/data/"
		for f in *.sql; do
			if [ -f "$f" ]; then
				wp --path=/var/www/html db import "$f"
			fi
		done
		cd /var/www/html
	fi

	# Activate the custom theme if it exists
	if [ -d "${REPO_ROOT}/themes/epdc-base" ]; then
		echo 'Activating epdc-base theme...'
		wp theme activate epdc-base 2>/dev/null || echo 'Theme activation will be available after Apache starts'
	fi
else
	echo 'Already configured'
	# Still try to activate the theme in case it was not activated before
	if [ -d "${REPO_ROOT}/themes/epdc-base" ]; then
		wp theme activate epdc-base 2>/dev/null || true
	fi
fi

wp option update home "http://localhost:${WP_PORT}" >/dev/null 2>&1 || true
wp option update siteurl "http://localhost:${WP_PORT}" >/dev/null 2>&1 || true
