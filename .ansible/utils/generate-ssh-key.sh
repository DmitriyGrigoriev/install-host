#!/bin/bash
# Send ssh key name as command line parameter to generate keys
# Generated keys will write into ~/.ssh directory
# command line simple: ./generate-ssh-key.sh github_dimag_rsa
# How to send args from shell to playbook:
# https://stackoverflow.com/questions/44138407/pass-bash-script-arguments-to-ansible-command-in-script

ansible-playbook ./utils/generate-ssh.yml -e "$*"
