## add host to server ssh-key
```shell
echo '192.168.12.21    datx-stg-mongo01'| sudo tee -a /etc/hosts
echo '10.48.15.120    tpc-mongo-sdc-dev-01'| sudo tee -a /etc/hosts

```
## Copy client ssh-key

```shell
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVaV+4oJHIRSbEMHuWQ2bA0ta1S+W+dB53jQf3dto35AOoqRJgLiLMhVP9fGQPh+unb+3CUZl8bFZWFxHfFs4FZV+0ttCMgmRxc8n0Oegdb86dEko8/zDnHEG3bjhUzwciWzvn7FJ4ChYq9jWJC8jkiTpTZDMibtAdo5tTWFtFHB+B6b2D3JH1/GxZzJ0PxT7tZ9HES0+FMVvFFMI5BzhXjdYuHIkAdjhP6UPv0uAmEWncWvQYAgYq7Oz5vAWcprVKY9BRjBx0ThmWfZXAhNYwUaaguoCSlwMpckwcjjFFf7O70F1rZulGG+PvhghDMrUYgASl0lwE2t6yBrKZZmpUGY0xp8dqKYWQHbG1sd1Kv+Nau7usl8xttwTrVLBTGeql78Dv7a1aThzQGy6v7JiGcyE9jwUXSjC/K3ObFABpYsV8iIRCpgag1jJUfeOdy2JZHf2EPvFddcNJa6IxccR7j3qowvlHJ/9DG0r65B6B8yNeue/7BGUW/OXlWU3wHqTeovNAopCZupNrwtTJPkqhtLAqBS6q4pUtJPw0EfRaBuSWiR7T8UknmtnZ/C5OvJxekwPEz9O6aYWvRaQyp+wxT+KY9Gk1Jxymh3tHkx56y55sazVBjnTSTadJzPL0Ri6Z50Q79tWiJV2gHN8hR6jcAyxeNXhltsFDuMvRDNuoMQ== datxbackup@192.168.0.11' |sudo tee -a /home/datxbackup/.ssh/authorized_keys

```
## Test ssh
```shell
ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no datxbackup@datx-stg-mongo01
ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no datxbackup@tpc-mongo-sdc-dev-01

## config backup target server need backup
ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no datxbackup@datx-stg-mongo01 "sudo mkdir -p /opt/backup/ /var/log/backup/ /data/backup/ && sudo chown datxbackup.datxbackup /opt/backup/ /var/log/backup/ /data/backup/ -R "
ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no datxbackup@tpc-mongo-sdc-dev-01 "sudo mkdir -p /opt/backup/ /var/log/backup/ /data/backup/ && sudo chown datxbackup.datxbackup /opt/backup/ /var/log/backup/ /data/backup/ -R "

# Source
server_ip="192.168.12.21"
hostname="datx-stg-mongo01"
env="Development"
db_type="Mongo"

# Destination
des_server_ip="10.48.15.120"
des_hostname="tpc-mongo-sdc-dev-01"
env="Development"
db_type="Mongo"

    mkdir -p /opt/backup/adhoc/$server_ip/
    rm -f /opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh 
    cp "/opt/backup/backup-mongodb_ori.sh" "/opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh"
    
    sed -i 's/server_ip="192.168.0.22"/server_ip="'$server_ip'"/g' /opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh
    sed -i 's/hostname="datx-mongo02"/hostname="'$hostname'"/g' /opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh
    sed -i 's/remote_backup_ip="192.168.0.110"/remote_backup_ip="'$des_server_ip'"/g' /opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh
    sed -i 's/backup/middleware/data/backup/g' /opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh

    server_ip="192.168.12.21"
    time rsync -avzP -e "ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no" /opt/backup/adhoc/$server_ip/backup-adhoc-mongodb_ori.sh datxbackup@$hostname:/opt/backup/

    hostname="tpc-mongo-sdc-dev-01"
    hostname="datx-stg-mongo01"
    time rsync -avzP -e "ssh -i /home/datxbackup/.ssh/id_rsa -o StrictHostKeyChecking=no" /home/datxbackup/.ssh/id_rsa datxbackup@$hostname:/home/datxbackup/.ssh/

8. Create a key file for mongodb
# on Primary server tpc-mongo-sdc-dev-01
openssl rand -base64 756 > /opt/mongo-keyfile
# copy file key mongo sang các node
rsync -avzP -e "ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no" /opt/mongo-keyfile root@tpc-mysql-mongo-sdc-dev-02:/opt/
rsync -avzP -e "ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no" /opt/mongo-keyfile root@tpc-mysql-mongo-sdc-dev-03:/opt/

# phân quyền file key ở all nodes
chmod 400 /opt/mongo-keyfile
chown mongodb:mongodb /opt/mongo-keyfile