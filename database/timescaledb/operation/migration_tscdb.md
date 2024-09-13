
source 10.0.0.11
patronictl -c /etc/patroni.yml list datx-tsdb01
$ 9fqmWLIDGdkMaSG2XnBiyIY9

dest: 10.48.6.12
patronictl -c /etc/patroni.yml list timescaledb-cluster
$ 9fqmWLIDGdkMaSG2XnBiyIY9


airflow_stag
datadb
dev_pms
fmarket
mass_marketing_db
postgres
sendgrid
trading_monitor




# view db


# 1 . Backup 

## all db 
time pg_dumpall -U postgres -h 10.0.0.11 -f | gzip > all_databases_backup.sql.gz
time pg_dumpall -U postgres -h 10.48.6.12 -f | gzip > all_databases_backup_10.48.6.12.sql.gz

pg_dump -U postgres -h 10.48.6.12 -d prod_pms -a -F c -b -v -f prod_pms_10.48.6.12.backup
pg_dumpall -U postgres -h 10.0.0.11 | gzip > all_databases_backup.sql.gz
pg_dumpall -U postgres -h 10.48.6.13 | gzip > all_databases_backup.sql.gz
## Sao lưu tài khoản người dùng và quyền hạn riêng:

$ pg_dumpall -U postgres -h 10.0.0.11 -g -f /opt/backup/global_backup_10.0.0.11.sql
$ 9fqmWLIDGdkMaSG2XnBiyIY9

$ pg_dumpall -U postgres -h 10.48.6.12 -g -f /opt/backup/global_backup_10.48.6.12.sql
$ 9fqmWLIDGdkMaSG2XnBiyIY9



## all db
pg_dump -U postgres -h 10.0.0.11 -d airflow_stag -F c -b -v -f airflow_stag_full.backup
pg_restore -U postgres -h 10.48.6.12 -C -d postgres -v airflow_stag_full.backup

pg_dump -U postgres -h 10.0.0.11 -d datadb -F c -b -v -f datadb.backup
pg_restore -U postgres -h 10.48.6.12 -C -d datadb -v datadb.backup


pg_dump -U postgres -h 10.0.0.11 -d fmarket -F c -b -v -f fmarket.backup
pg_restore -U postgres -h 10.48.6.12 -C -d fmarket -v fmarket.backup

pg_dump -U postgres -h 10.0.0.11 -d mass_marketing_db -F c -b -v -f mass_marketing_db.backup
pg_restore -U postgres -h 10.48.6.12 -C -d mass_marketing_db -v mass_marketing_db.backup

pg_dump -U postgres -h 10.0.0.11 -d sendgrid -F c -b -v -f sendgrid.backup
pg_restore -U postgres -h 10.48.6.12 -C -d sendgrid -v sendgrid.backup

pg_dump -U postgres -h 10.0.0.11 -d trading_monitor -F c -b -v -f trading_monitor.backup
pg_restore -U postgres -h 10.48.6.12 -C -d trading_monitor -v trading_monitor.backup

### info file 

1. Backup 10.48.6.12 old / datxadmin@10.48.6.13  / /opt/backup/postgresql/all_databases_backup.sql.gz
2. Backup 10.0.0.11 old / /data/backup/postgresql / all-database-2024-09-11_01h00m.sql.gz
3. file new /opt/backup and  /opt/restore/datadb.backup
4. global account new backup /opt/backupg/lobal_backup.sql