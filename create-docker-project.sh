#!/bin/bash

NC='\033[0m' # No Color
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CURRENT_FOLDER=$(pwd)

# Create variables
echo -e "${YELLOW}#########################################################################################${NC}\r"
echo -e "${YELLOW}############################ CONFIGURE A NEW DOCKER PROJECT #############################${NC}\r"
echo -e "${YELLOW}#########################################################################################${NC}\r"
printf '\n'
printf "CREATE NEW DOCKER PROJECT? (${GREEN}y${NC}/${RED}n${NC}):"
read RESPOND
RESPOND=$(echo "${RESPOND}" | tr '[:upper:]' '[:lower:]')
if [[ ("${RESPOND}" == "y") ]]; then
  printf '\n'

  # Project name.
  read -p "PROYECT NAME (Lowercase and without spaces): " PROJECT_NAME
  export PROJECT_NAME
  if [[ "${PROJECT_NAME}" == "" ]]; then
    printf "${RED}PROJECT NAME is required!${NC}"
    printf '\n'
    exit 1
  fi
  printf '\n'
  if [ -d ${CURRENT_FOLDER}"/"${PROJECT_NAME} ]
  then
    printf "${RED}PROJECT NAME already exists!${NC}"
    printf '\n'
    exit 1
  fi

  echo -e "${YELLOW}#########################################################################################${NC}\r"
  echo -e "${YELLOW}################################ CREATING DOCKER PROJECT ################################${NC}\r"
  echo -e "${YELLOW}#########################################################################################${NC}\r"

  # Download Easy docker drupal and set variables to .env file.
  cd ${CURRENT_FOLDER}
  echo ${CURRENT_FOLDER}
  if [[ "${CURRENT_FOLDER}" == "/docker_projects" ]]; then
    # Git clone
    git clone https://github.com/albertoperezdosaula/easy-docker-drupal ${PROJECT_NAME}
    cd ${PROJECT_NAME}
    source ./scripts/initialize.sh ${PROJECT_NAME}
  fi

  printf "${GREEN}[OK] Installation completed succesfully!${NC}"
  printf '\n'
  exit 1

else
  printf "${RED}[CANCELED] Installation canceled!${NC}"
  printf '\n'
  exit 1
fi
