tpc-activeMQ-rnd-stg-01     10.48.5.50      MASTER
tpc-activeMQ-rnd-stg-02     10.48.5.51      SLAVE

# 1. install ActiveMQ for all node

## Set hostname
nano /etc/hosts

#ActiveMQ
10.48.5.50      master          activemq-master.datxasia.local
10.48.5.51      slave           activemq-slave.datxasia.local

## a. Update time
        apt upgrade -y
        sudo apt install ntp -y
        sudo timedatectl set-timezone Asia/Ho_Chi_Minh
        timedatectl

mkdir -p /opt/activeMQ/
cd /opt/activeMQ/ 

chmod +x install_activemq.sh
./install_activemq.sh

# 2. Config Master

chmod +x configure_master.sh
./configure_master.sh

# 3. Config Slave
chmod +x configure_slave.sh
./configure_slave.sh

# 4.Check 
sudo systemctl stop activemq

sudo systemctl daemon-reload

sudo systemctl restart activemq

sudo systemctl status activemq

nano /opt/activemq/conf/activemq.xml
## Bắn thử mess trên master
chmod +x send_message.sh
./send_message.sh


## Nhận mess trên slave
chmod +x receive_message.sh
./receive_message.sh

# Kiểm tra kết nối
telnet tpc-activeMQ-rnd-stg-02 61616
telnet tpc-activeMQ-rnd-stg-01 61616

# Kiểm tra logs
tail -f /opt/activemq/data/activemq.log





    <networkConnectors>
        <networkConnector name="bridge-to-slave" uri="static:(tcp://10.48.5.51:61617)" duplex="true"/>
    </networkConnectors>


    <networkConnectors>
        <networkConnector name="bridge-to-master" uri="static:(tcp://10.48.5.50:61616)" duplex="true"/>
    </networkConnectors>