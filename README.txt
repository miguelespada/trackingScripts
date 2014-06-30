Dependencias

— 
sudo apt-get install python-mysqldb
sudo apt-get install python-pyproj

--- 
MYSQL 
mysql> create database rally
mysql> use rally
mysql> source unity.sql

---
Allow remote connections

mysql>GRANT ALL ON *.* to user@'%' IDENTIFIED BY 'password'; 

---
To find UTM ref zone
http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html