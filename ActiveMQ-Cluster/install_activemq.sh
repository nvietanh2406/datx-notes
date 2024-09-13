#!/bin/bash

# Update and install Java
sudo apt update
sudo apt install -y openjdk-11-jdk wget

# Download and extract ActiveMQ
wget https://archive.apache.org/dist/activemq/5.17.0/apache-activemq-5.17.0-bin.tar.gz
tar -xvzf apache-activemq-5.17.0-bin.tar.gz
sudo mv apache-activemq-5.17.0 /opt/activemq

# Create ActiveMQ service
sudo bash -c 'cat <<EOF > /etc/systemd/system/activemq.service
[Unit]
Description=Apache ActiveMQ
After=network.target

[Service]
Type=forking
ExecStart=/opt/activemq/bin/activemq start
ExecStop=/opt/activemq/bin/activemq stop
User=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'


# Set password
# Define variables
JETTY_REALM_FILE="/opt/activemq/conf/jetty-realm.properties"
ADMIN_USER="admin"
ADMIN_PASS="31bf2479-710d-4998-ac62-ef848781da91"
USER_USER="user"
USER_PASS="ee938936-3766-4f7d-85c1-a45015a41520"

# Create a backup of the original jetty-realm.properties file
cp "$JETTY_REALM_FILE" "$JETTY_REALM_FILE.bak"

# Update passwords in jetty-realm.properties
# Check if the user entries exist
if grep -q "^$ADMIN_USER:" "$JETTY_REALM_FILE"; then
    sed -i "s/^$ADMIN_USER:.*/$ADMIN_USER: $ADMIN_PASS, admin/" "$JETTY_REALM_FILE"
else
    echo "$ADMIN_USER: $ADMIN_PASS, admin" >> "$JETTY_REALM_FILE"
fi

if grep -q "^$USER_USER:" "$JETTY_REALM_FILE"; then
    sed -i "s/^$USER_USER:.*/$USER_USER: $USER_PASS, user/" "$JETTY_REALM_FILE"
else
    echo "$USER_USER: $USER_PASS, user" >> "$JETTY_REALM_FILE"
fi
echo "Passwords updated successfully."
cat "$JETTY_REALM_FILE"

# Create backup ActiveMQ config

cp /opt/activemq/conf/activemq.xml /opt/activemq/conf/activemq.xml.origin

# Reload systemd and enable ActiveMQ service
sudo systemctl daemon-reload
sudo systemctl enable activemq
sudo systemctl restart activemq