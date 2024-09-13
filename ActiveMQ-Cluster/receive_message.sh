#!/bin/bash

/opt/activemq/bin/activemq consumer --brokerUrl tcp://10.48.5.51:61616 --destination queue://test.queue --messageCount 10
