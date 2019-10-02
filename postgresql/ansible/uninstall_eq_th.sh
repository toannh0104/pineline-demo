#!/bin/sh
ansible-playbook -i ./inventory_eq_th.cfg -e host_key_checking=False -vvvvv -K playbook04_uninstall.yml
