#!/bin/bash

/opt/activemq/bin/activemq producer --brokerUrl tcp://10.48.5.50:61616 --destination queue://test.queue --messageCount 10 --message "Hello, ActiveMQ Cluster!"
