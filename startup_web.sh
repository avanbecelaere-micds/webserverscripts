#!/bin/bash
#
# Script: startup_web.sh
# Author: Andy Van Becelaere  
# Date: 2016.01.30 - 01
# 
# Purpose: installs base webserver applications 
# for ubuntu webservers
# 
# Notes: In development
# 
# Update OS and packages
sudo apt update -y && sudo apt upgrade -y
#
# Install & upgrade pip
sudo apt install python-pip -y
sudo pip install --upgrade pip
# Install awscli
sudo pip install awscli
# Install & Configure Apache
sudo apt install apache2 -y
myip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4) #grab public ip
sudo echo -e "ServerName" $myip >> /etc/apache2/apache2.conf #append ServerName to apache2.conf
sudo systemctl restart apache2  #restart apache
sudo mv /var/www/html/index.html /var/www/html/index.old #rename index.html
# Create new index.php file to replace index.html
sudo echo -e "<center><h1>this website is under construction</h1>\n<h3>please check back later</h3></center>" >> /var/www/html/index.php
# Install MySQL Server
sudo apt install -y mysql-server
# Configure MySQL Server
sudo service mysqld start
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE test;"
mysql -e "FLUSH PRIVILEGES;"
# Install PHP
sudo apt install php libapache2-mod-php php-mcrypt php-mysql -y
sed -i -e's/DirectoryIndex index.html index.cgi index.pl index.php/DirectoryIndex index.php index.html index.cgi index.pl/' /etc/apache2/mods-enabled/dir.conf
sudo service apache2 restart #restart apache
sudo apt-get install php-cli #install php command line interface
# Install PhpMyAdmin
sudo apt install -y phpmyadmin apache2-utils
sudo echo -e "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf #add phpmyadmin line to apache config file
sudo service apache2 restart #restart apache
# Secure PHPMyAdmin
sed -i -e's/DirectoryIndex index.php/DirectoryIndex index.php\n    AllowOverride All/' /etc/phpmyadmin/apache.conf #edit config file to add AllowOverride All
sudo echo -e "AuthType Basic\nAuthName \"Restricted Files\"\nAuthUserFile /etc/apache2/.phpmyadmin.htpasswd\nRequire valid-user" >> /usr/share/phpmyadmin/.htaccess #create .htaccess file
sudo htpasswd -c /etc/apache2/.phpmyadmin.htpasswd micdsadmin #set password for admin access
sudo service apache2 restart #restart apache
#test3