#!/bin/bash
HOMEDIR=/home/ec2-user
MYSQL_ROOT_PASSWORD=${DBPassword}

yum update -y

amazon-linux-extras install lamp-mariadb10.2-php7.2

echo Installing packages... >> $HOMEDIR/user_data_log
echo Please ignore messages regarding SELinux...
yum install -y \
httpd \
mariadb-server \
php \
php-gd \
php-mbstring \
php-mysqlnd \
php-xml \
php-xmlrpc

echo Packages installed successfully >> $HOMEDIR/user_data_log

echo configuring MySQL >> $HOMEDIR/user_data_log
echo $MYSQL_ROOT_PASSWORD > $HOMEDIR/MYSQL_ROOT_PASSWORD
chown ec2-user $HOMEDIR/MYSQL_ROOT_PASSWORD

echo Starting database service... >> $HOMEDIR/user_data_log
sudo systemctl start mariadb
sudo systemctl enable mariadb
echo Database service started >> $HOMEDIR/user_data_log

echo Setting up basic database security... >> $HOMEDIR/user_data_log
mysql -u root <<DB_SEC
UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOT_PASSWORD') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
DB_SEC
echo Database security in place >> $HOMEDIR/user_data_log

echo Configuring Apache... >> $HOMEDIR/user_data_log
usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo Apache configured >> $HOMEDIR/user_data_log

echo Starting Apache... >> $HOMEDIR/user_data_log
sudo systemctl start httpd
sudo systemctl enable httpd
echo Apache started >> $HOMEDIR/user_data_log

echo Installing Wordpress >> $HOMEDIR/user_data_log
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz -C /home/ec2-user
sudo systemctl start mariadb
echo Wordpress installed >> $HOMEDIR/user_data_log

echo configuring Wordpress >> $HOMEDIR/user_data_log
sudo cp /home/ec2-user/wordpress/wp-config-sample.php /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/database_name_here/${DBName}/" /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/username_here/${DBUser}/" /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/password_here/${DBPassword}/" /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/localhost/${rdsendpoint}/" /home/ec2-user/wordpress/wp-config.php
sudo cp -r /home/ec2-user/wordpress/* /var/www/html/
sudo systemctl restart httpd
echo Wordpress configured >> $HOMEDIR/user_data_log

#install a stress test app to test auto scaling
echo Installing and configuring a stress test tool >> $HOMEDIR/user_data_log
yum update -y --security
amazon-linux-extras install epel -y
yum -y install stress
mkdir /var/www/html/stress
cd /var/www/html/stress
wget http://aws-tc-largeobjects.s3.amazonaws.com/CUR-TF-100-TULABS-1/10-lab-autoscaling-linux/s3/ec2-stress.zip
unzip ec2-stress.zip
echo Stress test tool installed and configured >> $HOMEDIR/user_data_log

echo UserData has been successfully executed. >> $HOMEDIR/user_data_log