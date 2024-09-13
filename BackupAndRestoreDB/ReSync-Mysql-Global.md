#1. Sync data
# on 136.186.108.61
$ byobu-screen -DDR hh
mysqldump -u root -p --databases commodity commodityDb globaldb hsx indices |gzip >  $(date +"%Y%m%d")-datxau-db-glo01.sql.gz
-- Dat@2023

mysql -u root -p 

time rsync -avzP root@datxau-db-glo01:/data/mysql/20240716-datxau-db-glo01.sql.gz /data/mysql/

20240716-datxau-db-glo01.sql

mysql -u root -p < 20240716-datxau-db-glo01.sql

# on 192.168.0.61

backup_date=""
$ byobu-screen -DDR hh
rsync -avzP ubuntu@136.186.108.61:/home/ubuntu/"${backup_date}"-datxau-db-glo01.sql.gz .
gzip -d "${backup_date}"-datxau-db-glo01.sql.gz .

mysql -u root -p

drop database commodity;
drop database commodityDb;
drop database globaldb;
drop database hsx;
drop database indices;


create database commodity;
create database commodityDb;
create database globaldb;
create database hsx;
create database indices;

mysql -u ubuntu -p < "${backup_date}"-datxau-db-glo01.sql

ubuntu / Invoice@2019

#2. Config DB Replicate:
# on 136.186.108.61
$ byobu-screen -DDR hh
$ mysql -u root -p

show master status\G

*************************** 1. row ***************************
File: mysql-bin.xxx
Position: yyy
Binlog_Do_DB:
Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)

#Note: xxx, yyy

# on 192.168.0.61
$ byobu-screen -DDR hh
$ mysql -u root -p

stop slave;
reset slave all;
CHANGE MASTER TO MASTER_HOST = '136.186.108.61', MASTER_USER = 'replica', MASTER_PASSWORD = 'Wm0C7TNZYC3PCnYINwbWax$ukR', MASTER_LOG_FILE = 'mysql-bin.000016', MASTER_LOG_POS = 262752722;
start slave;

#Voi xxx, yyy lay tu tren:

# Verify:
show slave status\G