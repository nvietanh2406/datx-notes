datx-stg-mongo01-TO-tpc-mongo-sdc-dev-01



# 2. Mirgration

# backup
backup_user="mongo-root"
backup_pass="w2tWZe3HKJHcgxLLQoudnp4d"
backup_auth_db="admin"
local_backup_path="/data/backup/mongodb"
backup_file="${local_backup_path}"/all-database-$(date +%Y-%m-%d_%Hh%Mm).gz

time mongodump --authenticationDatabase="${backup_auth_db}" --username="${backup_user}" --password="${backup_pass}" --gzip --archive="${backup_file}"

# transfer
hostname="tpc-mongo-sdc-dev-01"
rsync -avzP --bwlimit=90000 -e "ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no" /data/backup/mongodb/all-database-2024-06-*.gz datxbackup@$hostname:/data/backup/mongodb/


# Run
# Check thông tin prymary
mongosh -u mongo-root -p --authenticationDatabase admin
w2tWZe3HKJHcgxLLQoudnp4d
mongosh -u backupUser -p --authenticationDatabase admin
PtZUE9KkEMKviFazn2ipJ3kgoShf2SQf
rs.status()

# Tạm dừng đồng bộ hóa trên các secondary
    rs.freeze(7200) # 2h dong bang
# remove slave node để không mất master khi restore
rs.remove("10.48.15.121:27017")
rs.remove("10.48.15.122:27017")

#restore
mongorestore -u mongo-root --authenticationDatabase=admin --drop --gzip --archive=/data/backup/mongodb/all-database-2024-06-29_18h31m.gz
# w2tWZe3HKJHcgxLLQoudnp4d

# tại slave node check db và xóa các db đang tồn tại
```shell
# check db
db.getMongo().getDBNames().forEach(function(dbName) {
    var dbStats = db.getSiblingDB(dbName).stats();
    print("- " + dbName + " (" + (dbStats.dataSize / 1024 / 1024).toFixed(4) + " MB)");
});

```

# resync cluster node ( add từng node đợi sync xong)
rs.add("10.48.5.12")
rs.add("10.48.5.13")
# check 
use local
db.oplog.rs.find().sort({$natural:-1}).limit(1)
# Khởi động mongod với cấu hình này:
mongod --config /etc/mongod.conf

# Link 
mongodb:#mongo-root:w2tWZe3HKJHcgxLLQoudnp4d@10.48.15.120:27017,10.48.15.121:27017,10.48.15.122:27017/?replicaSet=rsdev01&readPreference=primary&authMechanism=DEFAULT&authSource=admin




### thay đổi ip cấu hình mongo cluster (nếu cần)
```shell
# Lấy cấu hình hiện tại
var cfg = rs.conf()

# In ra cấu hình cũ
print("Cấu hình cũ:")
printjson(cfg)

# Thay đổi địa chỉ
cfg.members[0].host = "10.48.5.11:27017"

# In ra cấu hình mới
print("\nCấu hình mới:")
printjson(cfg)

# Áp dụng cấu hình mới
print("\nĐang áp dụng cấu hình mới...")
rs.reconfig(cfg)

# Kiểm tra lại status
print("\nStatus sau khi thay đổi:")
printjson(rs.status())
```
### xóa db (nếu cần)
```shell
# Thiết lập read preference
db.getMongo().setReadPref("secondary")

# Lấy danh sách các database cần xóa
var dbsToDelete = [];
try {
  dbsToDelete = db.getMongo().getDBNames().filter(function(dbName) {
    return !['admin', 'config', 'local'].includes(dbName);
  });
} catch (e) {
  print("Lỗi khi lấy danh sách database: " + e);
}

# In ra danh sách các database sẽ bị xóa
print("Các database sẽ bị xóa:");
printjson(dbsToDelete);

# Xóa các database
dbsToDelete.forEach(function(dbName) {
  print("Đang xóa database: " + dbName);
  try {
    db.getSiblingDB(dbName).dropDatabase();
  } catch (e) {
    print("Lỗi khi xóa database " + dbName + ": " + e);
  }
});

# Kiểm tra kết quả
var remainingDBs = [];
try {
  remainingDBs = db.getMongo().getDBNames();
} catch (e) {
  print("Lỗi khi lấy danh sách database còn lại: " + e);
}

print("\nCác database còn lại sau khi xóa:");
printjson(remainingDBs);

# In ra số lượng database đã xóa
print("\nSố lượng database đã xóa: " + (dbsToDelete.length));
print("Số lượng database còn lại: " + remainingDBs.length);
```