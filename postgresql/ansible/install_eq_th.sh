#!/bin/sh
#yum --enablerepo=extras install -y epel-release
#yum install -y ansible

ansible-playbook -i ./inventory_eq_th.cfg -e "@vars/parameters_eq_th.yml" -vvvvv -K ./playbook01_common_postgres.yml ./playbook02_master_node.yml ./playbook03_replica_node.yml
