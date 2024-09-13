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
    10.48.9.20      minio-01        minio1.datxasia.com.vn
    10.48.9.21      minio-02        minio2.datxasia.com.vn

## d. Tạo tài khoản minio-user

    sudo useradd -r minio-user -s /sbin/nologin

# 2. Cài đặt minio

## a. Tải xuông Min IO binary
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
sudo mv minio /usr/local/bin/

## b. tạo tư mục data minio
    wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20240704142545.0.0_amd64.deb -O minio.deb
    sudo dpkg -i minio.deb


## c. Tạo nơi lưu trữ
    sudo mkdir -p /mnt/disk1 /mnt/disk2
    groupadd -r minio-user
    useradd -M -r -g minio-user minio-user
    chown minio-user:minio-user /mnt/disk1 /mnt/disk2 -R
    chmod -R 775 /mnt/disk1 /mnt/disk2 -R

# 3. Khởi chạy  minio

## a. Sửa file 
### minio-01 and minio-02
sudo systemctl stop minio
rm /etc/default/minio
sudo tee /etc/default/minio <<EOF
# MinIO storage locations
MINIO_VOLUMES="/mnt/disk1"
# MINIO_VOLUMES="http://minio{1...2}.datxasia.com.vn/mnt/disk1"
# MINIO_VOLUMES="http://minio1.datxasia.com.vn/mnt/disk1 http://minio2.datxasia.com.vn/mnt/disk1"
# MINIO_VOLUMES="//10.48.9.20/mnt/disk1 http://10.48.9.21/mnt/disk1"

# MinIO listen address
MINIO_OPTS="--address :9000 --console-address :9443"
# MINIO_OPTS="--console-address :9443" 
# MINIO_OPTS="--console-address :9001" 

# MinIO accound admin
MINIO_ACCESS_KEY="admin"
MINIO_SECRET_KEY="4a5!78l2v1944o0ZK^Pk7v8bl00cMl"

# MinIO accound root
# Set the root username. This user has unrestricted permissions to
# perform S3 and administrative API operations on any resource in the
# deployment.
#
# Defer to your organizations requirements for superadmin user name.

MINIO_ROOT_USER=minioadmin
# Set the root password
#
# Use a long, random, unique string that meets your organizations
# requirements for passwords.
MINIO_ROOT_PASSWORD="QCbnF6yTw6wePszpkgEXDW9L3fStXY"
EOF
cat /etc/default/minio
sudo systemctl daemon-reload
sudo systemctl restart minio
sudo systemctl status minio


## b. cấu hình servicce

$ nano /usr/lib/systemd/system/minio.service

sudo systemctl stop minio
rm /usr/lib/systemd/system/minio.service
# sudo tee /usr/lib/systemd/system/minio.service <<EOF

[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
Type=notify
WorkingDirectory=/usr/local
User=minio-user
Group=minio-user
#ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Turn-off memory accounting by systemd, which is buggy.
# MemoryAccounting=no

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
# TimeoutStopSec=infinity
TimeoutSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
EOF
cat /usr/lib/systemd/system/minio.service

# Built for ${project.name}-${project.version} (${project.name})
```

## c. Khởi chạy dịch vụ

sudo systemctl daemon-reload
sudo systemctl enable minio.service
sudo systemctl restart minio
sudo systemctl status minio


# test dịch vụ minio
curl -v http://minio-01.example.com:9000/mnt/disk1
curl -v http://minio-02.example.com:9000/mnt/disk1

curl -v http://minio1.datxasia.com.vn:9000/mnt/disk1
curl -v http://minio2.datxasia.com.vn:9000/mnt/disk1
curl -v http://minio{1...2}.datxasia.com.vn:9000/mnt/disk1


# tìm dịch vụ web 
sudo netstat -tulnp | grep minio
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      81560/minio
tcp6       0      0 :::36507                :::*                    LISTEN      81560/minio
tcp6       0      0 ::1:9000                :::*                    LISTEN      81560/minio
tcp6       0      0 :::9000                 :::*                    LISTEN      81560/minio


```
# 4. Cài đặt Minio mornitor with Prometheus on k8s

## a. config HA listent for Prometheus

acl prod_prometheus hdr(host)       -i prometheus.datx.vn
use_backend backend_prod_prometheus     if prod_prometheus

backend backend_prod_prometheus
    mode http
    balance roundrobin
    option httpchk GET /
    server k8s-prod01-worker01 10.0.129.21:32009 check
    server k8s-prod01-worker02 10.0.129.22:32009 check
    server k8s-prod01-worker03 10.0.129.23:32009 check
    server k8s-prod01-worker04 10.0.129.24:32009 check


## b. Set file hosts đến địa chỉ HA có cấu hình tới k8s bên trên

    Mô hình khai báo mornitor minio qua prometheus
    
    Minio-01:9000 --- 
                     | -----> HA (minio-srv.datx.vn ) -------> HA prometheus.datx.vn  ---> Backen prometheus on K8s workers:32009 
    Minio-02:9000 ---             Service storage     mornitor

echo '10.0.129.100    prometheus.datx.vn'| sudo tee -a /etc/hosts

# 5. public domain console mino
## a. change HA

acl prod_tpc_minio_console hdr(host)       -i minio.datx.vn
use_backend backend_prod_tpc_minio_console    if prod_tpc_minio_console

backend backend_prod_tpc_minio_console
    mode http
    balance roundrobin
    option httpchk GET /
    server tpc-minio-infra-prod-01 10.48.9.20:9443 check
    server tpc-minio-infra-prod-02 10.48.9.21:9443 check