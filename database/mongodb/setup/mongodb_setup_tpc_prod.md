# Mongo tpc setup


| Role        | IP Addres      | Hostname                 | vCPU    | RAM       | Disk  |
|-------------| ---------------|--------------------------|---------|-----------|-------|
| mongodb     | 10.48.6.21     | tpc-mongodb-sdc-prod-01  | 2vCPU   | 4G RAM    | 200G  | 
| mongodb     | 10.48.6.22     | tpc-mongodb-sdc-prod-02  | 2vCPU   | 4G RAM    | 200G  |
| mongodb     | 10.48.6.23     | tpc-mongodb-sdc-prod-03  | 2vCPU   | 4G RAM    | 200G  |

1. Open Firewall
# on all servers
sudo ufw allow from 10.48.6.0/24

vim /etc/sysctl.conf
============
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6 = 1
============
sysctl -p

# II. Install mongodb 6.0
1. Update && upgrade
sudo apt update && sudo apt upgrade

2. Add MongoDB Repository on Ubuntu 20.04
sudo echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

3. Integrate the MongoDB GPG key
curl -sSL https://www.mongodb.org/static/pgp/server-6.0.asc  -o mongoserver.asc
gpg --no-default-keyring --keyring ./mongo_key_temp.gpg --import ./mongoserver.asc
gpg --no-default-keyring --keyring ./mongo_key_temp.gpg --export > ./mongoserver_key.gpg
sudo mv mongoserver_key.gpg /etc/apt/trusted.gpg.d/

4. Update repo
sudo apt update

5. Install MongoDB 6.0 on Ubuntu 20.04
sudo apt install mongodb-org
# Install with 1 version:
sudo apt-get install -y mongodb-org=6.0.4 mongodb-org-database=6.0.4 mongodb-org-server=6.0.4 mongodb-mongosh=1.6.2 mongodb-org-mongos=6.0.4 mongodb-org-tools=6.0.4
