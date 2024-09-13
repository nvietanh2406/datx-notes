#!/bin/bash
set -x

# constant var
start_time=$(date +%Y-%m-%d_%Hh%Mm)
end_time=""
hostname=$(hostname -s)
server_ip=$(ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')
remote_backup_ip="192.168.0.110"
env="Production"
db_type="PostgreSQL"
local_backup_path="/data/backup/postgresql"
discord_error_webhook="https://dscsecurities.webhook.office.com/webhookb2/c6aaa5c8-d455-478f-9bd4-34da9cdf8b7c@86364773-c0e8-4f58-ad10-a0a53daa5d41/IncomingWebhook/49411272b6de403e983d1af22355dfd8/373ef22c-2b28-4692-916f-44f4793d5b79"
discord_ok_webhook="https://dscsecurities.webhook.office.com/webhookb2/c6aaa5c8-d455-478f-9bd4-34da9cdf8b7c@86364773-c0e8-4f58-ad10-a0a53daa5d41/IncomingWebhook/49411272b6de403e983d1af22355dfd8/373ef22c-2b28-4692-916f-44f4793d5b79"
remote_backup_path="${remote_backup_ip}::database/${server_ip}/"
backup_file="${local_backup_path}"/all-database-$(date +%Y-%m-%d_%Hh%Mm).sql.gz
keep_day=7
backup_file_size=0
file_size_min=1000
backup_user="postgres"
backup_pass="0e82-707e-4209-899"
log_dir="/var/log/backup"
log_file="$log_dir/backup-postgresql.log"
# constant var Postg
pg_host="10.80.2.48"
pg_user="postgres"
pg_password="0e82-707e-4209-899"
pg_database="logs_db"
pg_table="backup_logs"
export PGPASSWORD="$pg_password"

# Declaration function
log() {
        if [ -n "$1" ]
        then
                IN="$1"
        else
                read IN
        fi
        DateTime=$(date "+%Y/%m/%d %H:%M:%S")
        echo -e "${DateTime}\t${IN}" >> "$log_file"
}

die() {
        log "ERROR: $1"
        exit 1
}

#OK: 2021216
#NOK: 14177041

function generate_post_data {
    cat <<EOF
{
  "avatar_url": "https://i.imgur.com/oBPXx0D.png",
  "content": "$1",
  "embeds": [{
    "color": "$2",
    "title": "Server Information",
    "fields":[
      {
        "name": "Enviroment",
        "value": "${env}",
        "inline": true
      },
      {
        "name": "IP Address",
        "value": "${server_ip}",
        "inline": true
      },
      {
        "name": "Hostname",
        "value": "${hostname}",
        "inline": true
      },
      {
        "name": "DB Type",
        "value": "${db_type}",
        "inline": true
      },
      {
        "name": "Start Time",
        "value": "${start_time}",
        "inline": true
      },
      {
        "name": "End Time",
        "value": "$4",
        "inline": true
      },
      {
        "name": "Local backup file",
        "value": "${backup_file}",
        "inline": false
      },
      {
        "name": "Local backup file size",
        "value": "$3",
        "inline": false
      }
    ]
  }]
}
EOF
}

# Hàm kiểm tra kết nối MySQL và tạo DB/bảng nếu chưa tồn tại
check_and_create_postgres() {
    # Kiểm tra database có tồn tại hay không
    if psql -h "$pg_host" -U "$pg_user" -d postgres -c "\c $pg_database" 2>/dev/null; then
        echo "Database $pg_database đã tồn tại."
    else
        echo "Tạo database $pg_database..."
        psql -h "$pg_host" -U "$pg_user" -d postgres -c "CREATE DATABASE $pg_database;"
    fi

    # Kiểm tra bảng có tồn tại hay không
    if psql -h "$pg_host" -U "$pg_user" -d "$pg_database" -c "\dt $pg_table" 2>/dev/null | grep -q "$pg_table"; then
        echo "Bảng $pg_table đã tồn tại."
    else
        echo "Tạo bảng $pg_table..."
        psql -h "$pg_host" -U "$pg_user" -d "$pg_database" << EOF
        CREATE TABLE $pg_table (
            id SERIAL PRIMARY KEY,
            backup_file VARCHAR(255),
            file_size VARCHAR(50),
            start_time TIMESTAMP,
            end_time TIMESTAMP,
            server_ip VARCHAR(15),
            hostname VARCHAR(255),
            env VARCHAR(50),
            db_type VARCHAR(50)
);
EOF
    fi
}

#Log started backup
log "Started backup"

#create backup folder
mkdir -p ${local_backup_path} ${log_dir}

# Create a backup
if pg_dumpall -U "$backup_user" | gzip > "${backup_file}"
then
  backup_file_size=$(wc -c "${backup_file}"| awk '{ print $1}')
  if [[ ${backup_file_size} -lt ${file_size_min} ]]
  then
    end_time=$(date +%Y-%m-%d_%Hh%Mm)
    backup_error_data=$(generate_post_data "${db_type} backup file size on server ${server_ip} is too small!!!" "14177041" "${backup_file_size}" "${end_time}")
    curl -H "Content-Type: application/json" -X POST -d "${backup_error_data}" "${discord_error_webhook}"
    die "Backup failed. ${db_type} backup file size on server ${server_ip} is too small \n"
  fi
else
  end_time=$(date +%Y-%m-%d_%Hh%Mm)
  backup_error_data=$(generate_post_data "No ${db_type} backup file on server ${server_ip} was created!" "14177041" "${backup_file_size}" "${end_time}")
  curl -H "Content-Type: application/json" -X POST -d "${backup_error_data}" "${discord_error_webhook}"
  die "Backup failed. No ${db_type} backup file on server ${server_ip} was created! \n"
fi

# Delete old backups
find $local_backup_path -mtime +$keep_day -delete

# Local and remote storage sync
if rsync -avz $local_backup_path $remote_backup_path
then
  log "Local backup file sended"
else
  end_time=$(date +%Y-%m-%d_%Hh%Mm)
  backup_file_size=$(du -hs "${backup_file}"| awk '{ print $1}')
  backup_error_data=$(generate_post_data "No ${db_type} backup file on servers ${server_ip} was synded!" "14177041" "${backup_file_size}" "${end_time}")
  curl -H "Content-Type: application/json" -X POST -d "${backup_error_data}" "${discord_error_webhook}"
  die "No ${db_type} backup file on servers ${server_ip} was synded! \n"
fi

backup_file_size=$(du -hs "${backup_file}"| awk '{ print $1}')
end_time=$(date +%Y-%m-%d_%Hh%Mm)
backup_ok_data=$(generate_post_data "${db_type} backup full on servers ${server_ip} was successfully created" "2021216" "${backup_file_size}" "${end_time}")
curl -H "Content-Type: application/json" -X POST -d "${backup_ok_data}" "${discord_ok_webhook}"

# Update database info backup

# Hàm insert thông tin backup vào PostgreSQL
insert_backup_info() {
    PGPASSWORD="$postgres_password" psql -h "$postgres_host" -U "$postgres_user" -d "$postgres_database" << EOF
INSERT INTO $postgres_table 
(backup_file, file_size, start_time, end_time, server_ip, hostname, env, db_type)
VALUES 
('$backup_file', '$backup_file_size', '$start_time', '$end_time', '$server_ip', '$hostname', '$env', '$db_type');
EOF
}


# Kiểm tra và tạo DB/bảng nếu cần
check_and_create_postgres

# Insert thông tin backup
insert_backup_info

#Log finished backup
log "Finished backup \n"
