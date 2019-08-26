#!/bin/sh
yum --enablerepo=extras install -y epel-release
yum install -y ansible

ansible-playbook -i ./inventory.cfg ./playbook01_common_postgres.yml --tags common -v -K

ansible-playbook -i ./inventory.cfg ./playbook02_master_node.yml --tags master -v -K