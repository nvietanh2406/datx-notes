# Backup Mongo apps Production 192.168.0.22,23,24
mongodump -u backupUser --authenticationDatabase=admin --db=order_manage -o ./ 
PtZUE9KkEMKviFazn2ipJ3kgoShf2SQf

mongosh -u backupUser -p --authenticationDatabase admin
PtZUE9KkEMKviFazn2ipJ3kgoShf2SQf

# Restore on Primary node
# Check  status
mongosh -u root -p --authenticationDatabase admin
i7rYlWNrXQMFHLsmOUuD4I4fATM6jaRx
rs.status()

cd /data/backup/mongodb
mongorestore -u backupUser --authenticationDatabase=admin --db=order_manage --drop ./order_manage


cd /data/backup/mongodb
time mongodump -u backupUser --authenticationDatabase=admin --db=order_manage -o ./ 
PtZUE9KkEMKviFazn2ipJ3kgoShf2SQf