#!/bin/bash
ansible-playbook ./roles/dimag.virtualenv/install-python-env.yml -i .hosts -c paramiko -e "hosts_group=staging" 
#--check --diff -vvvvv
#ansible-playbook ~/.ansible/install-staging.yml -e "hosts_group=staging"
