#!/bin/bash -xe

# Configure Authentication Variables which are used below
DBName=${DBName}
DBUser=${DBUser}
DBPassword=${DBPassword}
DBEndpoint=${DBEndpoint}
EFSFSID=${EFSFSID}

# Install system software - including Web and DB
sudo yum update -y
sudo yum install -y mariadb-server httpd wget amazon-efs-utils
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2


# Web and DB Servers Online - and set to startup

sudo systemctl enable httpd
sudo systemctl enable mariadb
sudo systemctl start httpd
sudo systemctl start mariadb

#Mount EFS File system
mkdir -p /var/www/html/wp-content
chown -R ec2-user:apache /var/www/
echo -e "$EFSFSID:/ /var/www/html/wp-content efs _netdev,tls,iam 0 0" >> /etc/fstab
mount -a -t efs defaults

# Install Wordpress
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
sudo tar -zxvf latest.tar.gz
sudo cp -rvf wordpress/* .
sudo rm -R wordpress
sudo rm latest.tar.gz


# Configure Wordpress

sudo cp ./wp-config-sample.php ./wp-config.php
sudo sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sudo sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sudo sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sudo sed -i "s/'localhost'/'$DBEndpoint'/g" wp-config.php   
sudo chown apache:apache * -R
