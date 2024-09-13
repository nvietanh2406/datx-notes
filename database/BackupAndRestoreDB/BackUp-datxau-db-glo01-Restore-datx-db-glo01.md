
136.186.108.61  datxau-db-glo01
192.168.0.61    datx-db-glo01

User root account:
root / Dat@2023

# Backup root@datxau-db-glo01
time mysqldump -h "localhost"  -u "root" -p"Dat@2023" --all-databases |gzip > "/data/mysql/all-databases-datxau-db-glo01-$(date +%Y-%m-%d_%Hh%Mm).sql.gz"

# ssh-key
## server uc

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbu6Vsu8ZZe7hkH5nsACU8rx6kTiKjjWXA1dNw0zQFI5vUkVIlig4GbLqDjZRGlii0cI+XSC9NVeWWpLdaiCuS929j8hGVk4LlvlDU6yQkhhsKneyzS4oMuWGsildoS/7ntvReHkYAH0jyDKQr1pW/XreyT6f3mWaVOT1i5q42JPKqMKL4LMrnj+s0BV7vX6HpaGwHcepM8kFaxxSMnxatGjDOnRxn71Wsj6QjNRPqc517p525gr3TSyPvO2Q+H8dfcxkK7hqdK5fCLelIINW4W3MZbFx9a1jHXagMqyD6PBNng/4fISLC2R7ZtxD7E6fIU6xXM5a1W+sZWzLnPeNOJbFVazFWBnlbLI5m26b1kuxqJ/JR3i64wCetfjKm/vuNbRdWQf7yn0tZk85mvIM9pX+19ekBy6A4oyaIxz+ZUuIdsaXq9tuFy/+l6h+XW/mIaTONy436aw2UPoC3Ycp6Ma96EdypiDMKamuLY8kQOZnit55tndLPdDYL5wRn4NdFg4u6el0YcsT5d63IvzmvNs6FmqSsf8KbajGHCFZ3OwR4ENdAGUQhyfVoxlwyDf5pGmHhm9CNiycwXL+2IKt4wELnknSTTzZvbBChpBhwk0YXXESrP2zz/5/EwP0ww68MDR5MXsuBmUMxOXCf391LeclvdhsAFOUk1ZlC8juJfw== root@datxau-db-glo01

## Server VN 
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDx3LeViJ/2J2M3RXuHHi1mnz7aeDxm+n0/VpwCh1admgiB0uhQl0pIYzYM3LMzoTuCB4/JfTJxRXPxzLu6cJ0ihbdCKEo7m+j6R8oJrM4YblTsltrdbjjz+wwM+1fMonaA/rD/4fXLdzAjbPGXm5XIUoXGb1AOKI275T2ghFrglNDjFnxJlLrkh/ODm2xMoRUFayRieymIWtY9UVl8ZqQZbHeUbic3efiMXn2gYpRfM5La8ICq1B/ftWarr/Hdme2oRJ8AG+Z8vBM1nXYi1y1thOPgikxicxNypgGCXW7WXlIQLWcEuiaSGQ7hXdL1PBFD14lNb/hVIezIpqHXHTelyI6ck7wjffwa37c3iCIFd99byEx0/hW6/VM/SNPqfzufeCx10GBdjYE/uMePwDHaAwIeDw2Odw2OFZRO0mo3O9eeFaF4npdZshpF8G62MCKPJAq5KkjpXYGcBtRxlpTnhph7lzSCvfWxgYadhqJNVeBmnBIbCA9x36DaE8XHr0XZiRGxxQV3oefmgb4/3EjNROFhjAS1lUDW683scsmG/rftJOesce2Kjni5cDJY46+ShSSEhe0+V1sdJcKeU9JO9jiWO2jJOpBrBNvpu8jfpdqBNJHqMu4mAP7EJVI2HK6MV61j0TjexBfKmbs6EbI3kGE2y2/vlKH0sDYa42exuw== root@datx-db-glo01

# Backup root@datxau-db-glo01
time mysqldump -h "localhost"  -u "root" -p"Dat@2023" --all-databases |gzip > "/data/mysql/all-databases-datx-db-glo01-$(date +%Y-%m-%d_%Hh%Mm).sql.gz"

file name: all-databases-datx-db-glo01-2024-07-15_19h45m.sql.gz

# copy file ve
time rsync -avzP root@datxau-db-glo01:/data/mysql/all-databases-datxau-db-glo01-2024-07-15_22h02m.sql.gz /data/mysql/

# Restore db VN
cd /data/backup/mysql
gunzip  all-databases-datxau-db-glo01-2024-07-15_22h02m.sql.gz
time mysql -u root -p  < all-databases-datxau-db-glo01-2024-07-15_22h02m.sql
-- Dat@2023

# stop db UC
mysql -u root -p
-- Dat@2023

# change pass replica
DROP USER IF EXISTS 'replica'@'%';

DROP USER IF EXISTS 'replica'@'datx-db-glo01';
CREATE USER 'replica'@'datx-db-glo01' IDENTIFIED BY 'Wm0C7TNZYC3PCnYINwbWax$ukR';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'datx-db-glo01';
FLUSH PRIVILEGES;

DROP USER IF EXISTS 'replica'@'42.96.42.249';
CREATE USER 'replica'@'42.96.42.249' IDENTIFIED BY 'Wm0C7TNZYC3PCnYINwbWax$ukR';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'42.96.42.249';
FLUSH PRIVILEGES;

DROP USER IF EXISTS 'replica'@'103.141.177.27';
CREATE USER 'replica'@'103.141.177.27' IDENTIFIED BY 'Wm0C7TNZYC3PCnYINwbWax$ukR';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'103.141.177.27';
FLUSH PRIVILEGES;

mysql> SELECT User, Host FROM mysql.user WHERE User='replica';
+---------+---------------+
| User    | Host          |
+---------+---------------+
| replica | %             |
| replica | 42.96.42.249  |
| replica | datx-db-glo01 |
+---------+---------------+
3 rows in set (0.00 sec)


## test login account
mysql -h 136.186.108.61 -u replica -p

-- Wm0C7TNZYC3PCnYINwbWax$ukR

mysql -h"136.186.108.61" -u"replica" -p'Wm0C7TNZYC3PCnYINwbWax$ukR'


# khoa bang db Uc
FLUSH TABLES WITH READ LOCK;

# Check vị trí và file binlog hiện tại
SHOW MASTER STATUS;

+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000404 |    32143 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

# change binlog slave
mysql -u root -p
-- Dat@2023

STOP SLAVE;
RESET SLAVE ALL;

        CHANGE MASTER TO
        MASTER_HOST='136.186.108.61',
        MASTER_USER='replica',
        MASTER_PASSWORD='Wm0C7TNZYC3PCnYINwbWax$ukR',
        SOURCE_LOG_FILE='mysql-bin.000404',
        SOURCE_LOG_POS=32143;

START SLAVE;
SHOW SLAVE STATUS\G

# Nếu ok unlock master

```json
mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 136.186.108.61
                  Master_User: replica
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000404
          Read_Master_Log_Pos: 32143
               Relay_Log_File: mysql-relay-bin.000002
                Relay_Log_Pos: 325
        Relay_Master_Log_File: mysql-bin.000404
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB: information_schema,performance_schema
```

UNLOCK TABLES;