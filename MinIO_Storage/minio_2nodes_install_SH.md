# Install minio cluster 2 nodes

    

# 1. Chuẩn bị 2 servers ubuntu 22.04

| minio Role  | IP Addres      | Hostname                 | vCPU    | RAM       | Disk  |
|-------------| ---------------|--------------------------|---------|-----------|-------|
| Storage     | 10.48.9.20     | tpc-minio-infra-prod-01  | 2vCPU   | 4G RAM    | 200G  | 
| Storage     | 10.48.9.21     | tpc-minio-infra-prod-02  | 2vCPU   | 4G RAM    | 200G  |

## a. Update time
        apt upgrade -y
        sudo apt install ntp -y
        sudo timedatectl set-timezone Asia/Ho_Chi_Minh
        timedatectl

## b. Open fw
sudo ufw status
sudo ufw allow 9000/tcp

# test
sudo netstat -tulnp | grep minio

## c. Set hostname
    nano /etc/hosts

    #MinIO Prod
    10.48.9.20      minio-01        minio1.datxasia.local
    10.48.9.21      minio-02        minio2.datxasia.local

## d. gen và add ssh key cho cả 2 server
#! master

ssh-keygen -t rsa -b 4096 
cat /home/datxbackup/.ssh/id_rsa.pub | sudo tee -a /home/datxbackup/.ssh/authorized_keys

#! add key của master node vào slave 
nano /home/datxbackup/.ssh/authorized_keys 


# 2. Cài đặt qua file sh, tạo và chạy scipt dưới ở master



mkdir -p /opt/minio-install/ &&
cd /opt/minio-install/ &&
nano minio-install.sh

```bash

#!/bin/bash

# Thông tin về các nodes
NODES=("10.48.9.20" "10.48.9.21")
HOSTNAMES=("minio1.datxasia.local" "minio2.datxasia.local")
MINIO_VOLUMES="http://minio{1...2}.datxasia.local:9000/data/minio"
MINIO_ACCESS_KEY="kzaSSwz8Gi7Ey0fWun#!kpjJ!1qCLU"
MINIO_SECRET_KEY="4d13b784-6761-4703-9f2e-f6aa0afa0049"

# Cài đặt MinIO trên cả hai nodes
for i in "${!NODES[@]}"; do
  NODE_IP=${NODES[$i]}
  HOSTNAME=${HOSTNAMES[$i]}
  
  ssh -t root@$NODE_IP << EOF
    # Cập nhật hệ thống
    apt update -y && apt upgrade -y

    # Kiểm tra và cài đặt MinIO nếu chưa có
    if ! command -v minio &> /dev/null; then
      echo "MinIO chưa được cài đặt. Đang tải và cài đặt MinIO..."
      wget https://dl.min.io/server/minio/release/linux-amd64/minio
      chmod +x minio
      mv minio /usr/local/bin/
    else
      echo "MinIO đã được cài đặt."
    fi

    # Tạo thư mục dữ liệu
    mkdir -p /data/minio

    # Kiểm tra và cài đặt mc (MinIO Client) nếu chưa có
    if ! command -v mc &> /dev/null; then
      echo "MinIO Client (mc) chưa được cài đặt. Đang tải và cài đặt mc..."
      wget https://dl.min.io/client/mc/release/linux-amd64/mc
      chmod +x mc
      mv mc /usr/local/bin/
    else
      echo "MinIO Client (mc) đã được cài đặt."
    fi

    # Tạo user và group cho MinIO nếu chưa tồn tại
    if ! id "minio-user" &> /dev/null; then
      useradd -r minio-user -s /sbin/nologin
      
    fi
    chown minio-user.minio-user /data/minio/ -R

    # Tạo file cấu hình MinIO
    cat > /etc/default/minio <<EOL
MINIO_VOLUMES="/data/minio"
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_ROOT_USER=$MINIO_ACCESS_KEY
MINIO_ROOT_PASSWORD=$MINIO_SECRET_KEY
EOL

    # Tạo file service MinIO
    cat > /etc/systemd/system/minio.service <<EOL
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target

[Service]
User=minio-user
Group=minio-user
EnvironmentFile=/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server \$MINIO_OPTS \$MINIO_VOLUMES
Restart=always
LimitNOFILE=65536
TasksMax=infinity
TimeoutSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOL

    # Tải và kích hoạt dịch vụ MinIO
    systemctl daemon-reload
    systemctl enable minio
    systemctl restart minio
EOF
done

# Đợi một chút để MinIO khởi động
sleep 10

# Cấu hình MinIO Cluster
MINIO_ENDPOINTS="http://${HOSTNAMES[0]}:9000 http://${HOSTNAMES[1]}:9000"
ssh -t root@${NODES[0]} << EOF
  mc alias set minio-01 http://${HOSTNAMES[0]}:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
  mc admin info minio-01
EOF

ssh -t root@${NODES[1]} << EOF
  mc alias set minio-02 http://${HOSTNAMES[1]}:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
  mc admin info minio-02
EOF

echo "MinIO cluster đã được cài đặt và cấu hình thành công trên các nodes: ${NODES[*]}"

