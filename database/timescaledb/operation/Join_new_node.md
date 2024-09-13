# Các bước thực hiện mô quát hóa các bước sau

Cài đặt node postgres tiêu chuẩn (postgres 14, pg_boundcer) --> Cài đặt etcd, join vào cụm etcd đang có (1) --> stop các postgres để dữ liệu wal tạm dừng --> (2) xóa dữ liệu cũ của node mới để tránh trùng lặp --> (3) xác định node leader và kéo dữ liệu về node mới này --> phân lại quyền cho các file -> (4) xóa file patroni.yml cũ và tạo mới file theo node mới --> (5) khởi động patroni và check thông tin 


(1)
etcdctl member add tpc-timescale-rnd-prod-01 http://10.48.6.11:2380
ETCDCTL_API=3 etcdctl --endpoints=10.48.6.11:2379,10.48.6.12:2379,10.48.6.13:2379 endpoint status 
etcdctl member list

(2)
systemctl stop patroni
sudo rm -rf /var/lib/postgresql/14/main
(3)
pg_basebackup -h 10.48.6.12 -D /var/lib/postgresql/14/main -U replicator -P --wal-method=stream
$ WjBMCibo53fPKgn3ppmYqkwf
sudo chown -R postgres:postgres /var/lib/postgresql/14/main
sudo chmod -R 0700 /var/lib/postgresql/14/main

(4)
rm /etc/patroni.yml && nano /etc/patroni.yml

```shell
scope: timescaledb-cluster
namespace: /service/
name: tpc-timescale-rnd-prod-01

restapi:
    listen: 10.48.6.11:8008
    connect_address: 10.48.6.11:8008

etcd:
    hosts:  10.48.6.11:2379,10.48.6.12:2379,10.48.6.13:2379

bootstrap:
    dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 10
        maximum_lag_on_failover: 1048576
        postgresql:
            use_pg_rewind: true
            use_slots: true
            parameters:
                wal_level: logical
                enable_partitionwise_aggregate: on
                jit: off
                max_prepared_transactions: 150
                statement_timeout: 0
                idle_in_transaction_session_timeout: 300000
                max_connections: 5000
                shared_preload_libraries: 'timescaledb'        # (change requires restart)
                shared_buffers: 1987MB
                effective_cache_size: 5926MB
                maintenance_work_mem: 1011452kB
                work_mem: 5057kB
                timescaledb.max_background_workers: 16
                max_worker_processes: 8 #23
                max_parallel_workers_per_gather: 2
                max_parallel_workers: 4
                wal_buffers: 16MB
                min_wal_size: 512MB
                max_wal_size: 1GB
                default_statistics_target: 100
                random_page_cost: 1.1
                checkpoint_completion_target: 0.9
                max_connections: 100
                max_locks_per_transaction: 64
                autovacuum_max_workers: 10
                autovacuum_naptime: 10
                effective_io_concurrency: 256
                timescaledb.last_tuned: '2024-08-06T17:04:22+07:00'
                timescaledb.last_tuned_version: '0.15.0'
    initdb:
    - encoding: UTF8
    - data-checksums

    pg_hba:
    - host replication replicator 127.0.0.1/32 md5
    - host replication replicator 10.48.6.11/0 md5
    - host replication replicator 10.48.6.12/0 md5
    - host replication replicator 10.48.6.13/0 md5
    - host all all 0.0.0.0/0 md5

    users:
        admin:
            password: admin
            options:
                - createrole
                - createdb

postgresql:
    listen: 0.0.0.0:5432
    connect_address: 10.48.6.11:5432
    data_dir: /var/lib/postgresql/14/main/   # thu muc chua data
    config_dir: /etc/postgresql/14/main/    # thu muc chua config
    bin_dir: /usr/lib/postgresql/14/bin   # thu muc chua file pg_controldata quan tri cluster cua postgres
    pgpass: /tmp/pgpass
    authentication:
        replication:
            username: replicator
            password: WjBMCibo53fPKgn3ppmYqkwf
        superuser:
            username: postgres
            password: 9fqmWLIDGdkMaSG2XnBiyIY9
    parameters:
        unix_socket_directories: '.'
        shared_preload_libraries: 'timescaledb'

watchdog:
    mode: automatic # Allowed values: off, automatic, required
    device: /dev/watchdog
    safety_margin: 5

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false
log:
  level: INFO
  path: /var/log/patroni/patroni.log
```
(5)
systemctl restart patroni
sudo journalctl -u patroni
patronictl -c /etc/patroni.yml list timescaledb-cluster