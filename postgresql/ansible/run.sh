#!/bin/sh
ansible-playbook -i ./inventory.cfg ./postgresql.yml --tags common -vv --K