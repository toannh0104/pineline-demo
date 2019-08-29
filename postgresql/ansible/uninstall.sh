#!/bin/sh
ansible-playbook -i ./inventory.cfg -e host_key_checking=False -vvvvv -K uninstall.yml