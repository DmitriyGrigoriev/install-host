#!/bin/bash
ansible-playbook ./roles/weareinteractive.vsftpd/install-vsftpd.yml -i .hosts -c paramiko -e "hosts_group=local" 
#--check --diff -vvvvv
