# 1 .backup data only on 0.13 and user
pg_dump -U postgres -h 10.0.0.13 -d prod_pms -a -F c -b -v | gzip > prod_pms.backup.gz

$ 9fqmWLIDGdkMaSG2XnBiyIY9

$ pg_dumpall -U postgres -h 10.0.0.13 -g -f /opt/backup/global_backup.sql
$ 9fqmWLIDGdkMaSG2XnBiyIY9


# 2.Restore on 6.12

gunzip -c prod_pms.sql.gz | psql -U postgres -h 10.48.6.12 -d prod_pms

$ 9fqmWLIDGdkMaSG2XnBiyIY9


# 2.2 Restore user on 6.12
edit file global_backup.sql and marking user admin

psql -U postgres -h 10.48.6.12 -d prod_pms -f global_backup.sql

nếu đã có user trước đó rùi thì bỏ qua