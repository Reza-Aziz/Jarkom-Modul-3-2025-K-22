#!/bin/bash
apt update
apt install -y mariadb-server mariadb-client
service mariadb start
mysql -u root
CREATE DATABASE elendil_db;
CREATE DATABASE isildur_db;
CREATE DATABASE anarion_db;
CREATE USER 'laraveluser'@'%' IDENTIFIED BY 'strongpassword';
GRANT ALL PRIVILEGES ON *.* TO 'laraveluser'@'%';
FLUSH PRIVILEGES;
EXIT;
nano /etc/mysql/mariadb.conf.d/50-server.cnf
bind-address = 0.0.0.0 #cari ini, dan rubah jadi 0.0.0.0
service mariadb restart