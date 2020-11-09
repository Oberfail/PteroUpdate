#!/bin/bash

echo ""
echo "Check out https://pterodactyl.io for the official way to update"
echo "Its not reccomended to use auto update scripts, they can be outdated or even break stuff."
echo "The latest Release of this Shell Script can be found on https://github.com/Oberfail/PteroUpdater"
read -p "Do you wish to Continue (y/n)" -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 
fi

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
echo "Your Panel has successfully been updated to the latest version"

#Pterodactyl Wings update to latest
cd /usr/local/bin
DOWNLOAD_URL=$(curl https://api.github.com/repos/pterodactyl/wings/releases/latest \
    | grep browser_download_url \
    | grep wings_linux_amd64 \
    | cut -d '"' -f 4)
curl -L --create-dirs -o /usr/local/bin/wings "$DOWNLOAD_URL"
chmod u+x /usr/local/bin/wings
systemctl restart wings
echo "Your Wings have successfully been updated to the latest version and have been restarted"
