# 1 . Backup 

## just data
pg_dump -U postgres -h 10.0.0.13 -d prod_pms -a -F c -b -v -f prod_pms.backup

## all data and users
pg_dumpall -U postgres -h 10.48.6.11 -d prod_pms -f prod_pms.sql

## Sao lưu tài khoản người dùng và quyền hạn riêng:
pg_dumpall -U postgres -h 10.48.6.11 -g -f global_backup.sql

$ pg_dumpall -U postgres -h 10.0.0.13 -g -f /opt/backup/global_backup.sql
$ 9fqmWLIDGdkMaSG2XnBiyIY9

# 2. Restore

## just data
pg_restore -U postgres -h 10.48.6.11 -d prod_pms -a -v prod_pms.backup.backup

## full data
psql --host=10.48.6.11 --port=5432 --username=postgres --dbname=prod_pms -f /opt/restore/tscdb-prod_pms-prod_pms-202408071654.sql

## just user
** edit and marking user postgre , data_read , data_write
psql -U postgres -h 10.48.6.11 -d prod_pms -f global_backup.sql

## test login user 
$ sudo -u replicator psql -h 10.48.6.11
$ WjBMCibo53fPKgn3ppmYqkwf

$ sudo -u postgres psql -h 10.48.6.11
$ 9fqmWLIDGdkMaSG2XnBiyIY9

## thử kết nối qua pgbouncer
```sql
psql -U postgres -h 10.48.6.11 -p 6432 -c "\conninfo"
$ 9fqmWLIDGdkMaSG2XnBiyIY9

psql -h 127.0.0.1 -p 6432 -U replicator -d postgres

$ WjBMCibo53fPKgn3ppmYqkwf

# 3. Check status

## check cluster patroni ctl
patronictl -c /etc/patroni.yml list timescaledb-cluster 

## check service
sudo systemctl status etcd
sudo systemctl status pgbouncer
sudo systemctl status postgresql
sudo systemctl status patroni



# 4. Patroni cmd



Khởi Động Lại Từng Node
Khởi Động Lại Từng Node:
Sử dụng lệnh patronictl để khởi động lại từng node của cluster:

sh
Sao chép mã
patronictl -c /etc/patroni/patroni.yml restart tpc-timescale-rnd-prod-01
patronictl -c /etc/patroni/patroni.yml restart tpc-timescale-rnd-prod-02
patronictl -c /etc/patroni/patroni.yml restart tpc-timescale-rnd-prod-03

Thay đổi patroni.yml với đường dẫn đến tệp cấu hình Patroni của bạn.

Khởi Động Lại Toàn Bộ Cluster
Khởi Động Lại Toàn Bộ Cluster:
Để khởi động lại toàn bộ cluster (tất cả các node), bạn có thể sử dụng lệnh:

sh
Sao chép mã
patronictl -c /etc/patroni/patroni.yml reload
Hoặc:

sh
Sao chép mã
patronictl -c /etc/patroni/patroni.yml restart


systemctl stop patroni
sudo rm -rf /var/lib/postgresql/14/main
pg_basebackup -h 10.48.6.12 -D /var/lib/postgresql/14/main -U replicator -P --wal-method=stream
$ WjBMCibo53fPKgn3ppmYqkwf
sudo chown -R postgres:postgres /var/lib/postgresql/14/main
sudo chmod -R 0700 /var/lib/postgresql/14/main
systemctl restart patroni

rm /etc/patroni.yml && nano 

sudo journalctl -u patroni




primary_conninfo = 'host=10.48.6.12 port=5432 user=replicator'

etcdctl member add tpc-timescale-rnd-prod-01 http://10.48.6.11:2380
ETCDCTL_API=3 etcdctl --endpoints=10.48.6.11:2379,10.48.6.12:2379,10.48.6.13:2379 endpoint status 
etcdctl member list

patronictl -c /etc/patroni.yaml reinit timescaledb-cluster tpc-timescale-rnd-prod-01
patronictl -c /etc/patroni/patroni.yml list timescaledb-cluster
patronictl -c /etc/patroni.yml list timescaledb-cluster