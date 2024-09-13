# I. Installation with ansible 
Get the ClusterControl Ansible role from Ansible Galaxy or Github.
Ansible Galaxy (always stable from master branch):

ansible-galaxy install severalnines.clustercontrol
```shell
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible
```

Github:

(master branch)

```shell

git clone https://github.com/severalnines/ansible-clustercontrol
cp -rf ansible-clustercontrol /etc/ansible/roles/severalnines.clustercontrol
Create playbooks. Refer to the Example Playbook section or examples directory.

Run the playbook.

ansible-playbook example-playbook.yml
```

# II. Installation with docker (/docker/README.md)

Supported database servers/clusters:
* Percona XtraDB Cluster
* MariaDB Galera Cluster
* MySQL/MariaDB (standalone & replication)
* MySQL Cluster (NDB)
* MongoDB (replica set & sharded cluster)
* PostgreSQL/EnterpriseDB (standalone & streaming replication)
* TimescaleDB (standalone & streaming replication)
* Redis (replication with Sentinel)
* SQL Server 2019/2022 for Linux (standalone & Availability Group)
* Elasticsearch

