I. Pre-Installation Requirements
#Reference
https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#repo-qg-apt-cluster-install
https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-install-configuration.html
https://dev.mysql.com/doc/mysql-cluster-excerpt/8.0/en/mysql-cluster-config-starting.html
https://dev.mysql.com/doc/refman/8.0/en/mysql-cluster-install-first-start.html

#Account Informatino
root / Dat@2023
#Server Informatino

CMC          -->  TPC
192.168.0.31 -->  10.48.6.31
192.168.0.41 -->  10.48.6.41
192.168.0.51 -->  10.48.6.51

# Open Firewall


# Disable IPv6
vim /etc/sysctl.conf
============
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6 = 1
============
sysctl -p

II. Install

B1: Adding the MySQL APT Repository
# on all servers
wget https://repo.mysql.com//mysql-apt-config_0.8.0-1_all.deb
dpkg -i mysql-apt-config_0.8.0-1_all.deb
sudo apt-get update

B2: Installing MySQL NDB Cluster
1. Install the components for SQL nodes:
# on server 192.168.14.22
sudo apt-get install mysql-cluster-community-server

2. Install the executables for management nodes:
# on server 192.168.14.21
sudo apt-get install mysql-cluster-community-management-server mysql-cluster-community-client

3. Install the executables for data nodes:
# on severs 192.168.14.23,24
sudo apt-get install mysql-cluster-community-data-node

B3: Initial Configuration of NDB Cluster
1. Configuring the data nodes and SQL nodes.
# on servers 192.168.14.23,24
vim /etc/my.cnf

=========================
[mysqld]
# Options for mysqld process:
ndbcluster                      # run NDB storage engine

[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=192.168.14.21  # location of management server
=========================

# on server 192.168.14.22
vim /etc/mysql/my.cnf
=========================
[mysqld]
# Options for mysqld process:
ndbcluster                          # run NDB storage engine
default_storage_engine=NDBCLUSTER   # set default engine

[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=192.168.14.21  # location of management server
=========================

$ systemctl restart mysql.service

2. Configuring the management node
# on server 192.168.14.21
mkdir /var/lib/mysql-cluster -p
vim /var/lib/mysql-cluster/config.ini

=======================================

[tcp default]
SendBufferMemory=2M
ReceiveBufferMemory=2M

# Increasing the sizes of these 2 buffers beyond the default values
# helps prevent bottlenecks due to slow disk I/O.

# MANAGEMENT NODE PARAMETERS

[ndb_mgmd default]
DataDir=/var/lib/mysql-cluster

# It is possible to use a different data directory for each management
# server, but for ease of administration it is preferable to be
# consistent.

[ndb_mgmd]
HostName=192.168.14.21
NodeId=21

# Using 2 management servers helps guarantee that there is always an
# arbitrator in the event of network partitioning, and so is
# recommended for high availability. Each management server must be
# identified by a HostName. You may for the sake of convenience specify
# a NodeId for any management server, although one is allocated
# for it automatically; if you do so, it must be in the range 1-255
# inclusive and must be unique among all IDs specified for cluster
# nodes.

# DATA NODE PARAMETERS

[ndbd default]
NoOfReplicas=2

# Using two fragment replicas is recommended to guarantee availability of data;
# using only one fragment replica does not provide any redundancy, which means
# that the failure of a single data node causes the entire cluster to shut down.
# It is also possible (but not required) in NDB 8.0 to use more than two
# fragment replicas, although two fragment replicas are sufficient to provide
# high availability.

LockPagesInMainMemory=1

# On Linux and Solaris systems, setting this parameter locks data node
# processes into memory. Doing so prevents them from swapping to disk,
# which can severely degrade cluster performance.

DataMemory=8192M

# The value provided for DataMemory assumes 4 GB RAM
# per data node. However, for best results, you should first calculate
# the memory that would be used based on the data you actually plan to
# store (you may find the ndb_size.pl utility helpful in estimating
# this), then allow an extra 20% over the calculated values. Naturally,
# you should ensure that each data node host has at least as much
# physical memory as the sum of these two values.

# ODirect=1

# Enabling this parameter causes NDBCLUSTER to try using O_DIRECT
# writes for local checkpoints and redo logs; this can reduce load on
# CPUs. We recommend doing so when using NDB Cluster on systems running
# Linux kernel 2.6 or later.

NoOfFragmentLogFiles=300
DataDir=/var/lib/mysql-cluster
MaxNoOfConcurrentOperations=100000

SchedulerSpinTimer=400
SchedulerExecutionTimer=100
RealTimeScheduler=1
# Setting these parameters allows you to take advantage of real-time scheduling
# of NDB threads to achieve increased throughput when using ndbd. They
# are not needed when using ndbmtd; in particular, you should not set
# RealTimeScheduler for ndbmtd data nodes.

TimeBetweenGlobalCheckpoints=1000
TimeBetweenEpochs=200
RedoBuffer=32M

# CompressedLCP=1
# CompressedBackup=1
# Enabling CompressedLCP and CompressedBackup causes, respectively, local
#checkpoint files and backup files to be compressed, which can result in a space
#savings of up to 50% over noncompressed LCPs and backups.

# MaxNoOfLocalScans=64
MaxNoOfTables=10000
MaxNoOfOrderedIndexes=102400

[ndbd]
HostName=192.168.14.23
NodeId=23

LockExecuteThreadToCPU=1
LockMaintThreadsToCPU=0
# On systems with multiple CPUs, these parameters can be used to lock NDBCLUSTER
# threads to specific CPUs

[ndbd]
HostName=192.168.14.24
NodeId=24

LockExecuteThreadToCPU=1
LockMaintThreadsToCPU=0

# You must have an [ndbd] section for every data node in the cluster;
# each of these sections must include a HostName. Each section may
# optionally include a NodeId for convenience, but in most cases, it is
# sufficient to allow the cluster to allocate node IDs dynamically. If
# you do specify the node ID for a data node, it must be in the range 1
# to 144 inclusive and must be unique among all IDs specified for
# cluster nodes.

# SQL NODE / API NODE PARAMETERS

[mysqld]
# SQL node options:
HostName=192.168.14.22            # Hostname or IP address
NodeId=22                        # Node ID for this data node

==================================

B4: Initial Startup of NDB Cluster
1. On the management host:
# on server 192.168.14.21
ndb_mgmd --initial -f /var/lib/mysql-cluster/config.ini

2. On each of the data node hosts:
# on servers 192.168.14.23, 192.168.14.24
mkdir -p /var/lib/mysql-cluster
ndbd

3. Verify cluster status:
# on management server 192.168.14.21
ndb_mgm -e show

Connected to Management Server at: 192.168.14.23:1186
Cluster Configuration
---------------------
[ndbd(NDB)]     2 node(s)
id=12   @192.168.14.25  (mysql-8.0.33 ndb-8.0.33, Nodegroup: 0, *)
id=13   @192.168.14.26  (mysql-8.0.33 ndb-8.0.33, Nodegroup: 0)

[ndb_mgmd(MGM)] 2 node(s)
id=10   @192.168.14.23  (mysql-8.0.33 ndb-8.0.33)
id=11   @192.168.14.24  (mysql-8.0.33 ndb-8.0.33)

[mysqld(API)]   2 node(s)
id=14 (not connected, accepting connect from 192.168.14.21)
id=15 (not connected, accepting connect from 192.168.14.22)
