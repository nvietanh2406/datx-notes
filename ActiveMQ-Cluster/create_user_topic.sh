#!/bin/bash

# Define variables
ACTIVEMQ_CONF_DIR="/opt/activemq/conf"
ACTIVEMQ_CONFIG_FILE="$ACTIVEMQ_CONF_DIR/activemq.xml"
JETTY_REALM_FILE="$ACTIVEMQ_CONF_DIR/jetty-realm.properties"

# Define users and passwords
declare -A USERS
USERS=( ["fss_price_board_fssuser_rw"]="03ba190c-d493-4c8d-9d1f-c3e693afd478" 
        ["fss_price_board_datxuser_rw"]="0d2e45c8-b191-4b92-bd2b-5b64a3e1ff22" 
        ["fss_price_board_datxuser_read"]="05162678-662c-4b1f-b9af-ca47b32fb399" )

# Define topics and permissions (read, write, admin)
declare -A TOPICS
TOPICS=(
    ["fss_price_board_beta"]="fss_price_board_fssuser_rw:fss_price_board_datxuser_rw:fss_price_board_datxuser_read"
)

# Backup the original configuration files
cp "$ACTIVEMQ_CONFIG_FILE" "$ACTIVEMQ_CONFIG_FILE.bak"
cp "$JETTY_REALM_FILE" "$JETTY_REALM_FILE.bak"

# Add users to jetty-realm.properties
for USER in "${!USERS[@]}"; do
    USER_PASS="${USERS[$USER]}"
    if grep -q "^$USER:" "$JETTY_REALM_FILE"; then
        sed -i "s/^$USER:.*/$USER: $USER_PASS, $USER/" "$JETTY_REALM_FILE"
    else
        echo "$USER: $USER_PASS, $USER" >> "$JETTY_REALM_FILE"
    fi
    echo "User $USER added to $JETTY_REALM_FILE."
done

# Function to create policy entries
create_policy_entry() {
    local topic=$1
    local users=$2
    local read_users=""
    local write_users=""
    local admin_users=""
    
    IFS=':' read -r -a user_array <<< "$users"
    for user in "${user_array[@]}"; do
        case "$user" in
            "fss_price_board_fssuser_rw")
                read_users+="$user,"
                write_users+="$user,"
                ;;
            "fss_price_board_datxuser_rw")
                read_users+="$user,"
                write_users+="$user,"
                admin_users+="$user,"
                ;;
            "fss_price_board_datxuser_read")
                read_users+="$user,"
                ;;
        esac
    done
    
    read_users=${read_users%,}
    write_users=${write_users%,}
    admin_users=${admin_users%,}
    
    echo "<policyEntry topic=\"$topic.>\" >"
    echo "  <authorizationEntry read=\"$read_users\" write=\"$write_users\" admin=\"$admin_users\"/>"
    echo "</policyEntry>"
}

# Add destination policies for topics in activemq.xml
POLICY_ENTRIES=""
for TOPIC in "${!TOPICS[@]}"; do
    USERS="${TOPICS[$TOPIC]}"
    POLICY_ENTRY=$(create_policy_entry "$TOPIC" "$USERS")
    POLICY_ENTRIES+="\n$POLICY_ENTRY"
done

# Insert policy entries into activemq.xml
sed -i "/<policyEntries>/a ${POLICY_ENTRIES}" "$ACTIVEMQ_CONFIG_FILE"

# Add topics to the destinations section in activemq.xml
DESTINATIONS_SECTION=$(grep -q "<destinations>" "$ACTIVEMQ_CONFIG_FILE")
if [ ! $DESTINATIONS_SECTION ]; then
    sed -i "/<\/broker>/i <destinations>" "$ACTIVEMQ_CONFIG_FILE"
    sed -i "/<\/broker>/i <\/destinations>" "$ACTIVEMQ_CONFIG_FILE"
fi

for TOPIC in "${!TOPICS[@]}"; do
    if ! grep -q "<topic physicalName=\"$TOPIC\"/>" "$ACTIVEMQ_CONFIG_FILE"; then
        sed -i "/<destinations>/a \    <topic physicalName=\"$TOPIC\"/>" "$ACTIVEMQ_CONFIG_FILE"
        echo "Topic $TOPIC added to $ACTIVEMQ_CONFIG_FILE."
    else
        echo "Topic $TOPIC already exists in $ACTIVEMQ_CONFIG_FILE."
    fi
done

# Restart ActiveMQ to apply changes
systemctl restart activemq

if [ $? -eq 0 ]; then
    echo "ActiveMQ restarted successfully."
else
    echo "Failed to restart ActiveMQ."
    exit 1
fi

echo "Topics created and permissions set for users."

