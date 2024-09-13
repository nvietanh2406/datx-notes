# migration mysql from 192.168.8.31 TO 10.48.5.31
From: datx-stg-db01 / 192.168.8.31
TO: tpc-mysql-mongo-sdc-dev-01 / 10.48.5.31 - 32
Type: Mysql
Env: Dev/stg

# Backup
time mysqldump -h"localhost" -u"mysqlbackup"  -p"3mTavkJ3W5Z&QR~W~Duy#rVW" --all-databases |gzip > "/data/backup/mysql/adhoc-time.sql.gz"

# transfer to master
hostname="tpc-mysql-mongo-sdc-dev-01"
rsync -avzP --bwlimit=90000 -e "ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no" /data/backup/mysql/adhoc-time.sql.gz datxbackup@$hostname:/data/backup/mysql

hostname="tpc-mysql-mongo-sdc-dev-02"
rsync -avzP --bwlimit=90000 -e "ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no" /data/backup/mysql/adhoc-time.sql.gz datxbackup@$hostname:/data/backup/mysql


## Khóa bảng bên master
FLUSH TABLES WITH READ LOCK;

## Ngắt kết nối master slave ( trên slave)
```shell
$ nano /etc/mysql/mysql.conf.d/mysqld.cnf


#server-id = 2
#relay-log = /var/log/mysql/mysql-relay-bin.log
#log_bin = /var/log/mysql/mysql-bin.log
#binlog_do_db = tên_database

$ sudo systemctl restart mysql
```

```sql
$ sudo mysql -u root -p
# Datx@2024$

$ mysql -u datadm -p 
# 5f0D4e60-5bac-4927-b17d-2a8bc1ae4733

STOP SLAVE;
RESET SLAVE ALL;
```

# Kiểm tra trên master xem đã ngắt chưa
```sql
SHOW SLAVE HOSTS;
```

# Restore

cd /data/backup/mysql
gunzip  adhoc-time.sql.gz
time mysql -u root -p  < adhoc-time.sql
# Datx@2024$

# kiểm tra và kết nối lại master slave

## check db
```shell

# Tạo file tạm thời để chứa câu lệnh SQL
server_ip="localhost"
backup_user="datadm"
backup_pass="5f0D4e60-5bac-4927-b17d-2a8bc1ae4733"
temp_file=$(mktemp)
cat << EOF > "$temp_file"
SELECT @@hostname AS Server, COUNT(*) AS TotalDatabases
FROM INFORMATION_SCHEMA.SCHEMATA;
SELECT '----------------------------', NULL;

SELECT
TABLE_SCHEMA AS DatabaseName,
COUNT(*) AS TableCount
FROM
INFORMATION_SCHEMA.TABLES
GROUP BY
TABLE_SCHEMA;
SELECT '----------------------------', NULL;

SET @randomDb = (SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA ORDER BY RAND() LIMIT 1);
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = @randomDb
ORDER BY RAND()
LIMIT 10;

EOF

# Thực thi câu lệnh SQL và lưu kết quả vào file result.txt
mysql -h"$server_ip" -u"$backup_user" -p"$backup_pass" < "$temp_file" > /data/backup/mysql/result.txt

# Xóa file tạm thời
rm "$temp_file"
cat /data/backup/mysql/result.txt
```
## start lại slave mode
```shell
$ nano /etc/mysql/mysql.conf.d/mysqld.cnf


server-id = 2
relay-log = /var/log/mysql/mysql-relay-bin.log
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = tên_database

$ sudo systemctl restart mysql
$ sudo systemctl status mysql
```


## sau khi kiểm 
MASTER
```sql
# check login account repl from slave
$ sudo mysql -h 10.48.5.31 -u repl_user -p
# Wm0C7TNZYC3PCnYINwbWax$ukR

$ sudo mysql -u root -p
# Datx@2024$
$ mysql -u datadm -p 
# 5f0D4e60-5bac-4927-b17d-2a8bc1ae4733

-- Trên Master tạo lại tài khoản do đổi ip slave (nếu cần)
	CREATE USER 'repl_user'@'10.48.5.0/24' IDENTIFIED WITH mysql_native_password BY 'Wm0C7TNZYC3PCnYINwbWax$ukR';
	GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'10.48.5.0/24';
    FLUSH PRIVILEGES;
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'Datx@2024$';


FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS;
```
SLAVES
```sql
$ sudo mysql -u root -p
# Datx@2024$
        CHANGE MASTER TO
        MASTER_HOST='10.48.5.31',
        MASTER_USER='repl_user',
        MASTER_PASSWORD='Wm0C7TNZYC3PCnYINwbWax$ukR',
        SOURCE_LOG_FILE='mysql-bin.000206',
        SOURCE_LOG_POS=198270087;

START SLAVE;
SHOW SLAVE STATUS\G
```

MASTER
```sql
# check connection slave
SHOW SLAVE HOSTS;
UNLOCK TABLES;
```

