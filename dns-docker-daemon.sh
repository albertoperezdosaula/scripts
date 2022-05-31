#!/bin/bash

NC='\033[0m' # No Color
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'

if [ ! -d "/etc/docker" ]
  then
    printf "${RED}Docker folder in /etc/docker does not exists!${NC}"
    printf '\n'
  exit 1
fi

printf "Add DNS to a new daemon.json [8.8.8.8]:"
read DNS_INPUT
DNS=${DNS_INPUT:=8.8.8.8}

sudo bash -c "echo { >> /etc/docker/daemon.json"
sudo bash -c "echo '  \"dns\": [\"${DNS}\"]' >> /etc/docker/daemon.json"
sudo bash -c "echo } >> /etc/docker/daemon.json"

sudo service docker restart
