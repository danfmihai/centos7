#!/bin/bash
clear

echo "##### Installing Apache Php and downloading wordpress #####"
echo
echo
read -p "Run the updates and install php httpd?  " answer
while true
do
  case $answer in
   [yY]* ) 
            yum update -y
            yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
            yum-config-manager --disable remi-php54
            yum-config-manager --enable remi-php73
            yum -y install httpd centos-release-scl.noarch bash-completion php php-common php-opcache php-mcrypt php-cli php-curl wget yum-utils mariadb mariadb-server php-mysql php-gd php-xml php-mbstring nano
            systemctl start httpd
            systemctl enable httpd
            systemctl start mariadb
            systemctl enable mariadb
            
           echo "Okay, just ran the script."
           break;;

   [nN]* ) break;;

   * )     echo "Dude, just enter Y or N, please."; break ;;
  esac
done
cd /var/www
echo "Downloading the latest wordpress...."
echo
wget https://wordpress.org/latest.tar.gz
tar -xf late*
## check if folder html exits ##
if [ ! -d /var/www/html ]
then
    mkdir html 
    rsync -a wordpress/ html/
fi

rsync -a wordpress/ html/
echo
echo "Fixing permissions..."
#cp wp-config-sample.php wp-config.php
chown -R apache:apache html/
find html/ -type d -exec chmod 750 {} \;
find html/ -type f -exec chmod 640 {} \;
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
echo "Creating database wpdb"
#mysql -u root -e "create database wpdb"; 
mysql -u root -e "SHOW DATABASES;"
sleep 3
mysql -u root -e "DROP DATABASE IF EXISTS wpdb;" 
mysql -u root -e "DROP USER IF EXISTS 'wp_user'@'localhost';" > /dev/null 2>&1
mysql -u root -e "SELECT user, host FROM mysql.user;"
mysql -u root -e "CREATE DATABASE wpdb; GRANT ALL PRIVILEGES ON wpdb.* TO wp_user@localhost IDENTIFIED BY 'password'"
mysql -u root -e "SHOW DATABASES;"
mysql -u root -e "SELECT user, host FROM mysql.user;"
echo
sleep 4
echo "Cleaning up..."
echo "##############"
rm -f lates*
rm -fr wordpress
touch /etc/httpd/conf.d/wp.conf
cat <<EOF>/etc/httpd/conf.d/wp.conf
<VirtualHost *:80>
  ServerAdmin admin@none.com
  DocumentRoot /var/www/html/
  ServerName 192.168.102.169
  ErrorLog /var/log/httpd/wp-error-log
  CustomLog /var/log/httpd/wp-acces-log common
</VirtualHost>
EOF
echo "### RESTART HTTPD ###"
systemctl restart httpd 
#cp html/wp-config-sample.php html/wp-config.php
#echo "$(pwd)"
echo "#### ALL DONE ####"
echo "Access the wordpress at localhost or your server ip address for the rest of the install"
php --version | awk '{print $1,$2}' 
echo 
httpd -v 
mysql --version
exit