#!/bin/bash

sudo systemctl stop activemq

sudo rm -rf /opt/activemq

sudo rm /etc/systemd/system/activemq.service

sudo systemctl daemon-reload
