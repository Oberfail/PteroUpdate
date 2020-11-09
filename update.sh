#!/bin/bash

#Pterodactyl Panel update to latest
cd /var/www/pterodactyl
php artisan down
DOWNLOAD_URL=$(curl https://api.github.com/repos/pterodactyl/panel/releases/latest \
    | grep browser_download_url \
    | grep panel.tar.gz \
    | cut -d '"' -f 4)
curl -L --create-dirs -o /var/www/pterodactyl/panel.tar.gz "$DOWNLOAD_URL"
tar -xzvf panel.tar.gz && rm -f panel.tar.gz
chmod -R 755 storage/* bootstrap/cache
composer install --no-dev --optimize-autoloader
php artisan view:clear
php artisan config:clear
php artisan migrate --force
php artisan db:seed --force
chown -R www-data:www-data * /var/www/pterodactyl
php artisan up
php artisan queue:restart

#Pterodactyl Wings update to latest
cd /usr/local/bin
DOWNLOAD_URL=$(curl https://api.github.com/repos/pterodactyl/wings/releases/latest \
    | grep browser_download_url \
    | grep wings_linux_amd64 \
    | cut -d '"' -f 4)
curl -L --create-dirs -o /usr/local/bin/wings "$DOWNLOAD_URL"
chmod u+x /usr/local/bin/wings
systemctl restart wings
