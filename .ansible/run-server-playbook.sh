#!/bin/bash

ansible-playbook ~/.ansible/install-staging.yml -e "hosts_group=staging"
