#!/bin/sh
yum --enablerepo=extras install -y epel-release
yum install -y ansible

ansible-playbook -i ./inventory.cfg ./postgresql.yml --tags common -v -K