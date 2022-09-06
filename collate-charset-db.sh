#!/bin/bash

NC='\033[0m' # No Color
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CURRENT_FOLDER=$(pwd)

printf '\n'
echo -e "${BLUE}########################################################${NC}\r"
echo -e "${BLUE}#########                                       ########${NC}\r"
echo -e "${BLUE}#########    SCRIPT SETEO COLLATE/CHARSE DB     ########${NC}\r"
echo -e "${BLUE}#########                                       ########${NC}\r"
echo -e "${BLUE}########################################################${NC}\n"
# Instrucciones.
printf "${YELLOW} INSTRUCCIONES ANTES DE EMPEZAR:\n${NC}"
printf " Dicho script permite cambiar el collate y charset de la BD.\n\n"
printf " Antes de lanzar el script compruebe lo siguiente:\n"
printf "   ${BLUE}1 -${NC} Situar el script en la misma carpeta que la .SQL.\n"

printf "\n${YELLOW}-----------------------------------------------------${NC}\n"
printf "${YELLOW} CONFIGURACIÓN PARA CONVERTIR COLLATE/CHARSET DB:${NC}\n\n"
# Collate name previous.
printf " ${BLUE}COLLATE NAME PREVIO A SUSTITUIR:${NC}"
read -p " Por ejemplo utf8mb4_0900_ai_ci: " COLLATE_PREVIOUS
export COLLATE_PREVIOUS
if [[ "${COLLATE_PREVIOUS}" == "" ]]; then
  printf " ${RED}COLLATE NAME PREVIO es requerido!${NC}\n"
  exit 1
fi
# New collate name.
printf " ${BLUE}COLLATE NAME NUEVO A SUSTITUIR:${NC}"
read -p " Por ejemplo utf8_general_ci: " COLLATE_NEW
export COLLATE_NEW
if [[ "${COLLATE_NEW}" == "" ]]; then
  printf " ${RED}COLLATE NAME NUEVO es requerido!${NC}\n"
  exit 1
fi
# Charset name previous.
printf " ${BLUE}CHARSET NAME PREVIO A SUSTITUIR:${NC}"
read -p " Por ejemplo utf8mb4: " CHARSET_PREVIOUS
export CHARSET_PREVIOUS
if [[ "${CHARSET_PREVIOUS}" == "" ]]; then
  printf " ${RED}CHARSET NAME PREVIO es requerido!${NC}\n"
  exit 1
fi
# New charset name.
printf " ${BLUE}CHARSET NAME NUEVO A SUSTITUIR:${NC}"
read -p " Por ejemplo utf8: " CHARSET_NEW
export CHARSET_NEW
if [[ "${CHARSET_NEW}" == "" ]]; then
  printf " ${RED}CHARSET NAME NUEVO es requerido!${NC}\n"
  exit 1
fi
# Database name.
printf " ${BLUE}DATABASE_NAME:${NC}"
read -p " Nombre del fichero SQL (Añade .sql al final): " DATABASE_NAME
export DATABASE_NAME
if [[ "${DATABASE_NAME}" == "" ]]; then
  printf " ${RED}DATABASE_NAME es requerido!${NC}\n"
  exit 1
fi

printf "\n"
printf " ${GREEN}Sustituyendo...${NC} CHARSET '$CHARSET_PREVIOUS' por '$CHARSET_NEW'\n"
printf " ${GREEN}Sustituyendo...${NC} COLLATE '$COLLATE_PREVIOUS' por '$COLLATE_NEW'\n\n"

sed -i "s/CHARSET=$CHARSET_PREVIOUS/CHARSET=$CHARSET_NEW/g" ${DATABASE_NAME}
sed -i "s/$COLLATE_PREVIOUS/$COLLATE_NEW/g" ${DATABASE_NAME}

printf " ${GREEN}Finalizado correctamente!${NC}\n"
