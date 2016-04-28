#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='12345678'
PROJECTFOLDER='myproject'

# create project folder
sudo mkdir "/var/www/html/${PROJECTFOLDER}"

# add a repo for php 5.6 - php5.9 would be downloaded without this
sudo apt-add-repository ppa:ondrej/php5-5.6

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# curl is not configured by default in this version
sudo apt-get -y install curl

# install apache 2.5 and php 5.6
sudo apt-get install -y apache2
sudo apt-get install -y php5

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECTFOLDER}"
    <Directory "/var/www/html/${PROJECTFOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# optional Drupal configuration
# optional commands for adding drush uncomment to enable
sudo composer global require drush/drush:dev-master
sudo ln -s /root/.composer/vendor/bin/drush /usr/bin/drush
sudo chmod 755 /root/

# add a Drupal db
#clean up first
#echo "Droping database drupal_vagrant if it already exists."
sudo mysql -root -p12345678 -e "DROP DATABASE IF EXISTS drupal_vagrant"

#echo "Creating new database drupal_vagrant"
sudo mysql -uroot -p12345678 -e "create database drupal_vagrant"

# drush dl drupal-7.x
# drush site-install standard --account-name=admin --account-pass=admin --db-url=mysql://root:12345678@localhost/drupal_vagrant