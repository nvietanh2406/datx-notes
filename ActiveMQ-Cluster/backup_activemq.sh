#!/bin/bash

# Define backup directory and timestamp
BACKUP_DIR="/data/backup/activemq"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/activemq_backup_$TIMESTAMP.tar.gz"

# Define ActiveMQ directories
CONF_DIR="/opt/activemq/conf"
DATA_DIR="/opt/activemq/data"
LOG_DIR="/opt/activemq/logs"

# constant var MySQL
mysql_host="10.48.9.110"
mysql_user="datadm"
mysql_password="5f0D4e60-5bac-4927-b17d-2a8bc1ae4733"
mysql_database="backupdb"
mysql_table="backup_logs"
start_time_logs=$(date +"%Y-%m-%d %H:%M:%S")

#logs
local_backup_path="/data/backup/mysql"
keep_day=7
backup_file_size=0
file_size_min=100
log_dir="/var/log/backup"
log_file="$log_dir/backup-mysql.log"
hostname=$(hostname -s)
server_ip=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
env="Development"
db_type="ActiveMQ"


# Hàm kiểm tra kết nối MySQL và tạo DB/bảng nếu chưa tồn tại
check_and_create_mysql() {
    if mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" -e "USE $mysql_database;" 2>/dev/null; then
        echo "Database $mysql_database đã tồn tại."
    else
        echo "Tạo database $mysql_database..."
        mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" -e "CREATE DATABASE $mysql_database;"
    fi

    if mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_database" -e "DESCRIBE $mysql_table;" 2>/dev/null; then
        echo "Bảng $mysql_table đã tồn tại."
    else
        echo "Tạo bảng $mysql_table..."
        mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_database" << EOF
CREATE TABLE $mysql_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    backup_file VARCHAR(255),
    file_size VARCHAR(50),
    start_time DATETIME,
    end_time DATETIME,
    server_ip VARCHAR(15),
    hostname VARCHAR(255),
    env VARCHAR(50),
    db_type VARCHAR(50)
);
EOF
    fi
}


# Create backup directory if it does not exist
mkdir -p "$BACKUP_DIR"

# Create a tarball backup of the ActiveMQ directories
tar -czf "$BACKUP_FILE" "$CONF_DIR" "$DATA_DIR" "$LOG_DIR"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed"
    exit 1
fi

# Optional: Remove backups older than 5 days
find "$BACKUP_DIR" -type f -name "activemq_backup_*.tar.gz" -mtime +5 -exec rm {} \;

# Check size backup
backup_file_size=$(du -hs "${BACKUP_FILE}"| awk '{ print $1}')

# Hàm insert thông tin backup vào MySQL
end_time=$(date +"%Y-%m-%d %H:%M:%S")
insert_backup_info() {
    mysql -h "$mysql_host" -u "$mysql_user" -p"$mysql_password" "$mysql_database" << EOF
INSERT INTO $mysql_table
(backup_file, file_size, start_time, end_time, server_ip, hostname, env, db_type)
VALUES
('$BACKUP_FILE', '$backup_file_size', '$start_time_logs', '$end_time', '$server_ip', '$hostname', '$env', '$db_type');
EOF
}

# Kiểm tra và tạo DB/bảng nếu cần
check_and_create_mysql

# Insert thông tin backup
insert_backup_info

echo "Old backups cleaned up."

# End of script
