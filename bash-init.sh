#!/bin/bash

echo Mount EFS >> $HOMEDIR/user_data_log
MOUNT_PATH="/var/www"
EFS_DNS_NAME=${efs_dns_name}
HOMEDIR=/home/ec2-user

[ $(grep -c $${EFS_DNS_NAME} /etc/fstab) -eq 0 ] && \
        (echo "$${EFS_DNS_NAME}:/ $${MOUNT_PATH} nfs nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab; \
                mkdir -p $${MOUNT_PATH}; mount $${MOUNT_PATH})

echo Install packages >> $HOMEDIR/user_data_log
yum -y update
amazon-linux-extras enable php7.4
yum -y install httpd mod_ssl php php-cli php-gd php-mysqlnd

echo -e '<IfModule mod_setenvif.c>\n\tSetEnvIf X-Forwarded-Proto "^https$" HTTPS\n</IfModule>' > /etc/httpd/conf.d/xforwarded.conf
sed -i 's/post_max_size = 8M/post_max_size = 128M/g'  /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g'  /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 600/g'  /etc/php.ini
sed -i 's/; max_input_vars = 1000/max_input_vars = 2000/g'  /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 300/g'  /etc/php.ini

systemctl enable --now httpd

firewall-cmd --add-service=http
firewall-cmd --add-service=https
firewall-cmd --runtime-to-permanent

# Download Wordpress
WP_ROOT_DIR=$${MOUNT_PATH}/html
LOCK_FILE=$${MOUNT_PATH}/.wordpress.lock
EC2_LIST=$${MOUNT_PATH}/.ec2_list
WP_CONFIG_FILE=$${WP_ROOT_DIR}/wp-config.php


SHORT_NAME=$(hostname -s)
echo "$${SHORT_NAME}" >> $${EC2_LIST}
FIRST_SERVER=$(head -1 $${EC2_LIST})

if [ ! -f $${LOCK_FILE} -a "$${SHORT_NAME}" == "$${FIRST_SERVER}" ]; then

echo Create lock to avoid multiple attempts >> $HOMEDIR/user_data_log
	touch $${LOCK_FILE}

# ALB monitoring healthy during initialization
	echo "OK" > $${WP_ROOT_DIR}/healthcheck.html
  
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
  sudo cp -r /home/ec2-user/wordpress/* $${WP_ROOT_DIR}
  rm -rf latest.tar.gz
  rm -rf Wordpress
  sudo systemctl restart httpd
  echo Wordpress configured >> $HOMEDIR/user_data_log
  cd $${MOUNT_PATH}
  mkdir $${WP_ROOT_DIR}/wp-content/uploads
  chown -R apache /var/www
  chgrp -R apache /var/www
  chmod 2775 /var/www
  find /var/www -type d -exec sudo chmod 2775 {} \;
  find /var/www -type f -exec sudo chmod 0664 {} \;
	

else
	echo "$(date) :: Lock is acquired by another server"  >> /var/log/user-data-status.txt
fi

# Reboot
reboot