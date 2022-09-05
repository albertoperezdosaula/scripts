#!/bin/bash

PROJECT_LAST_DRUPAL_VERSION='9.4.5'
PROJECT_PHP_VERSION_STABLE='7.4'

NC='\033[0m' # No Color
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CURRENT_FOLDER=$(pwd)

printf '\n'
echo -e "${BLUE}#######################################################################################${NC}\r"
echo -e "${BLUE}#############################                                 #########################${NC}\r"
echo -e "${BLUE}#############################    SCRIPT AUDITORÍA PORTALES    #########################${NC}\r"
echo -e "${BLUE}#############################                                 #########################${NC}\r"
echo -e "${BLUE}#######################################################################################${NC}\n"
# Instrucciones.
printf "${YELLOW} INSTRUCCIONES ANTES DE EMPEZAR:\n${NC}"
printf " Dicho script permite lanzar una auditoria completa sobre portales de Drupal 8 y 9.\n\n"
printf " Antes de lanzar el script compruebe lo siguiente:\n"
printf "   ${BLUE}1 -${NC} Ejecutar desde PRO o un entorno clonado al de PRO.\n"
printf "   ${BLUE}2 -${NC} Situar este script dentro de la carpeta raiz de Drupal.\n"
printf "   ${BLUE}3 -${NC} Comprueba que tu usuario de Linux tiene permisos para escribir en la carpeta Drupal.\n"
printf "   ${BLUE}4 -${NC} Este script asume que el proyecto está desplegado con GIT y Composer.\n\n"
# Paquetes.
printf "${YELLOW} PAQUETES A INSTALAR ANTES DE INICIAR EL PROCESO:\n${NC}"
printf ' 1 - jq\n'
printf ' 2 - phpcpd\n'
printf ' 3 - phpcs\n'
printf ' 4 - column\n\n'
printf "${BLUE} Actualmente te faltan por instalar estos paquetes:\n${NC}"
PACKAGES_INSTALLED=0
if ! [ -x "$(command -v jq)" ]; then
  printf "${RED} 1 - jq no esta installado.${NC}\n"
  PACKAGES_INSTALLED=1
fi
if ! [ -x "$(command -v phpcpd)" ]; then
  printf "${RED} 2 - phpcpd no esta installado.${NC}\n"
  PACKAGES_INSTALLED=1
fi
if ! [ -x "$(command -v phpcs)" ]; then
  printf "${RED} 3 - phpcs no esta installado.${NC}\n"
  PACKAGES_INSTALLED=1
fi
if ! [ -x "$(command -v column)" ]; then
  printf "${RED} 4 - column no esta installado.${NC}\n"
  PACKAGES_INSTALLED=1
fi
if [[ "${PACKAGES_INSTALLED}" < 1 ]]; then
  printf "${GREEN} Ninguno.${NC}\n\n"
fi
printf "${YELLOW}----------------------------------------------------------------------------${NC}\n\n"

################################################################################
################################ SCRIPT FUNCTIONS ##############################
################################################################################
script_configuration() {
  printf "\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
  printf "${YELLOW} CONFIGURACIÓN PREVIA DEL SCRIPT DE AUDITORÍA:${NC}\n\n"
  # Project name.
  printf " ${BLUE}NOMBRE PROYECTO:${NC}"
  read -p " En minúsculas y sin espacios, DEBE coincidir con la carpeta raiz de Drupal: " PROJECT_NAME
  export PROJECT_NAME
  if [[ "${PROJECT_NAME}" == "" ]]; then
    printf " ${RED}NOMBRE PROYECTO es requerido!${NC}\n"
    exit 1
  fi
  printf '\n'
  # Url.
  printf " ${BLUE}URL de PRO/VAL:${NC}"
  read -p " Indíquelo con http/https y sin slash final (por ejemplo: http://www.google.es): " PROJECT_PRO_URL
  export PROJECT_PRO_URL
  if [[ "${PROJECT_PRO_URL}" == "" ]]; then
    printf " ${RED}URL de PRO/VAL es requerida!${NC}\n"
    exit 1
  fi
  printf '\n'
  # Url local.
  printf " ${BLUE}URL de LOCAL:${NC}"
  read -p " Indíquelo con http/https y sin slash final (por ejemplo: http://google.vm): " PROJECT_LOCAL_URL
  export PROJECT_LOCAL_URL
  if [[ "${PROJECT_LOCAL_URL}" == "" ]]; then
    printf " ${RED}URL de LOCAL es requerida!${NC}\n"
    exit 1
  fi
  printf '\n'
  # Url Jenkins.
  printf " ${BLUE}URL de JENKINS:${NC}"
  read -p " Indíquelo con http/https y sin slash final (por ejemplo: http://jenkins.ci.google): " JENKINSURL
  export JENKINSURL
  if [[ "${JENKINSURL}" == "" ]]; then
    printf " ${RED}URL de JENKINS es requerida!${NC}\n"
    exit 1
  fi
  printf '\n'
  printf " ${BLUE}CONTENIDO OBSOLETO:${NC}"
  # Obsolete content (Determine the year to clasify obsolete content).
  read -p " Indique a partir de que año se considera obsoleto en contenido de Drupal (por ejemplo: 2018): " CONTENTOBS
  export CONTENTOBS
  if [[ "${CONTENTOBS}" == "" ]]; then
    printf " ${RED}El año es requerido!${NC}\n"
    exit 1
  fi
  # Workdir
  WORKDIR="/opt/drupal/web/${PROJECT_NAME}"
  cd ${WORKDIR}
  WORKROOT=$(vendor/bin/drush core-status --field=root)
  WORKDIR_CONFIG="${WORKROOT}/$(vendor/bin/drush core-status --field=config-sync)"
}

exit_script() {
  if [[ -z "$1" ]]; then
    printf " ${GREEN}[EJECUCIÓN FINALIZADA]${NC}"
  else
    printf " ${RED}[EJECUCIÓN CANCELADA]${NC}"
  fi
  printf '\n'
  printf '\n'
  exit;
}

################################################################################
################################# PROCESS SCRIPT ###############################
################################################################################
printf " DESEA CONTINUAR CON EL PROCESO (${GREEN}y${NC}/${RED}n${NC}):"
read RESPOND
RESPOND=$(echo "${RESPOND}" | tr '[:upper:]' '[:lower:]')
if [[ ("${RESPOND}" == "y") ]]; then

  script_execution() {
    opt=$1
    case $opt in
      "REV-DRUPAL")
        printf '\n'

        echo -e "${YELLOW}#######################################################################################${NC}\r"
        echo -e "${YELLOW}############################ REVISION DRUPAL (REV-DRUPAL) #############################${NC}\r"
        echo -e "${YELLOW}#######################################################################################${NC}\n"

        printf "${YELLOW} REV-DRUPAL-01 [AUTOMÁTICO]:${NC}\n"
        PROJECT_CURRENT_DRUPAL_VERSION=$(vendor/bin/drush core-status --field=drupal-version)
        printf " La ultima version de Drupal debería ser: ${PROJECT_LAST_DRUPAL_VERSION} sin embargo tenemos la: ${PROJECT_CURRENT_DRUPAL_VERSION}: "
        if [[ ${PROJECT_LAST_DRUPAL_VERSION} == ${PROJECT_CURRENT_DRUPAL_VERSION} ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-02 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Comprobar que los módulos contribuidos están soportados, se encuentran en su última versión estable y no están pendientes de actualizaciones de seguridad críticas para el entorno.\n"
        composer outdated 'drupal/*'

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-03 [AUTOMÁTICO]:${NC}\n"
        curl --head --silent "${PROJECT_PRO_URL}/user/login" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_PRO_URL}/user/login y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_PRO_URL}/user/login 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-04 [MANUAL]:${NC}\n"
        drush user-create ntt_test --mail="ntt_test123@nttdata.com" --password="ntt_test123"
        printf " Se ha creado el usuario: ntt_test (ntt_test123@nttdata.com) con password ntt_test123 sin roles asignados. Por favor, acceda a edición para intentar bloquear el usuario. Posteriormente borrelo."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-05 [SEMIAUTOMÁTICO]:${NC}\n"
        curl --head --silent "${PROJECT_PRO_URL}/robots.txt" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_PRO_URL}/robots.txt y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_PRO_URL}/robots.txt 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}\n\n"
          printf " Por favor, revise el robots.txt para comprobar que esta configurado de forma correcta.\n\n"
          curl "${PROJECT_PRO_URL}/robots.txt"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-06 [AUTOMÁTICO]:${NC}\n"
        curl --head --silent "${PROJECT_PRO_URL}/update.php" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_PRO_URL}/update.php y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_PRO_URL}/update.php 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-07 [AUTOMÁTICO]:${NC}\n"
        curl --head --silent "${PROJECT_PRO_URL}/cron.php" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_PRO_URL}/cron.php y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_PRO_URL}/cron.php 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt
        printf '\n'
        curl --head --silent "${PROJECT_PRO_URL}/cron" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_PRO_URL}/cron y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_PRO_URL}/cron 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-08 [AUTOMÁTICO]:${NC}\n"
        curl --head --silent "${PROJECT_PRO_URL}/xmlrpc.php" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_PRO_URL}/xmlrpc.php y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_PRO_URL}/xmlrpc.php 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-09 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " A continuación se muestran los ficheros .txt, .xml y .patch en el directorio: ${WORKDIR}\n\n"
        printf " Por favor compruebe si existen ficheros que no sea del core. (https://git.drupalcode.org/project/drupal)\n\n"
        find "${WORKDIR}/web" -maxdepth 1 -iname "*.txt"
        find "${WORKDIR}/web" -maxdepth 1 -iname "*.xml"
        find "${WORKDIR}/web" -maxdepth 1 -iname "*.patch"

        printf "\n\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-10 [MANUAL]:${NC}\n"
        printf " En esta prueba, Por favor compruebe lo siguiente sobre los módulos custom:\n"
        printf " * Nunca debería haber comentarios, nombres de variables, nombres de ficheros, etc en código que no sea en inglés.\n"
        printf " * En las funciones que tienen parámetros de entrada y / o salida, siempre se debería indicar de que tipo son (no poner type).\n"
        printf " * El código que ya no es utilizado debería eliminarse y no dejarlo comentado.\n"
        printf " * No debería haber funciones de más de 100 líneas."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-11 [MANUAL]:${NC}\n"
        printf " En esta prueba, Por favor compruebe lo siguiente sobre los módulos custom:\n"
        printf " * Comprobar los servicios REST con los que cuenta el portal, tanto a nivel custom como desde interfaz.\n"
        printf " * Comprobar si en el servicio, se pasan datos sensibles sin encriptar.\n"
        printf " * Comprobar que cuando se trate de un servicio que guarda datos en Drupal, se haga en dos fases, una para recibir un ACCESS_TOKEN y otra para realizar el proceso.\n"
        printf " * Si el servicio trae X cantidad de datos que tienen que importarse en Drupal. El servicio debería contar con un sistema que identifique cuales ya estan importados para evitar que aparezcan en el WS.\n"
        printf " * Si el Webservice esta usando para conectar Curl, comprobar que luego se cierra la conexión.\n"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-12 [SEMIAUTOMÁTICO]:${NC}\n"
        composer require drupal/security_review --no-interaction -q
        vendor/bin/drush en security_review -y -q
        vendor/bin/drush secrev --results 2>/dev/null

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-13 [AUTOMÁTICO]:${NC}\n"
        if ! [ -x "$(command -v phpcpd)" ]; then
          printf "${RED} PHPCPD no esta installado.${NC} Por favor, para poder ejecutar este test, instale phpcpd previamente.\n"
        else
          printf " El resultado de encontrar Copy&Paste sobre los módulos custom es: "
          phpcpd web/modules/custom >> copy.txt
          if [[ ! -z $(grep "No clones" "copy.txt") ]]; then
            printf "${GREEN}[OK]${NC}"
          else
            printf "${RED}[KO]${NC}"
            printf '\n'
            awk '/Found/{print $0}' copy.txt
          fi
          rm copy.txt
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-14 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Comprobando si Antibot está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep antibot
        printf '\n'
        printf " Comprobando si Captcha está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep captcha
        printf '\n\n'
        printf " Acceda a la página web ${PROJECT_PRO_URL} y navega en busca de algún formulario para comprobar si existe captcha."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-15 [AUTOMÁTICO]:${NC}\n"
        GITRESULT=$(git ls-files ${WORKDIR}/web/sites/default/settings.php)
        printf " El fichero ${WORKDIR}/web/sites/default/settings.php está: "
        if [[ "${WORKDIR}/${GITRESULT}" == "${WORKDIR}/web/sites/default/settings.php" ]]; then
          printf "${RED}[COMMITEADO]${NC}"
          printf '\n'
          printf " Revisa el fichero para comprobar si hay datos vulnerables.\n"
          GITRESULT=$(git ls-files ${WORKDIR}/web/sites/default/settings.local.php)
          printf " El fichero ${WORKDIR}/web/sites/default/settings.local.php está: "
          if [[ "${WORKDIR}/${GITRESULT}" == "${WORKDIR}/web/sites/default/settings.local.php" ]]; then
            printf "${RED}[COMMITEADO]${NC}"
            printf '\n'
            printf " Revisa el fichero para comprobar si hay datos vulnerables."
          else
            printf "${GREEN}[NO COMMITEADO]${NC}"
          fi
        else
          printf "${GREEN}[NO COMMITEADO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-16 [SEMIAUTOMÁTICO]:${NC}\n"
        PRIVATEFOLDER=$(vendor/bin/drush dd private)
        ROOTFOLDER=$(vendor/bin/drush dd)
        mkdir -p ${PRIVATEFOLDER}
        touch ${PRIVATEFOLDER}/test.txt && echo prueba > ${PRIVATEFOLDER}/test.txt
        PRIVATEURL=${PRIVATEFOLDER/$ROOTFOLDER/}
        curl --head --silent "${PROJECT_LOCAL_URL}${PRIVATEURL}/test.txt" >> curl.txt
        printf " Se comprueba la URL de ${PROJECT_LOCAL_URL}${PRIVATEURL}/test.txt y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${PROJECT_LOCAL_URL}${PRIVATEURL}/test.txt 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt
        printf '\n\n'
        printf " A continuación comprueba los permisos de la ruta: ${PRIVATEFOLDER}: "
        printf '\n\n'
        ls -la ${PRIVATEFOLDER}
        rm ${PRIVATEFOLDER}/test.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-17 [MANUAL]:${NC}\n"
        printf " Acceda a la página web ${PROJECT_PRO_URL} y navega en busca de algún formulario para comprobar los campos.\n\n"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-18 [MANUAL]:${NC}\n"
        printf " A continuación se muestran las vistas del sitio, las vistas deberían estar configuradas a un reference_entity y no como field.\n"
        VIEWS=$(vendor/bin/drush sql:query "SELECT name FROM config WHERE name LIKE 'views.view.%'");
        for VIEW in $VIEWS
        do
          printf " La vista ${VIEW} está configurada: "
          if [[ ! -z $(grep "type: fields" "${WORKDIR_CONFIG}/${VIEW}.yml") ]]; then
            printf "${RED}[KO]${NC}"
          else
            printf "${GREEN}[OK]${NC}"
          fi
          printf '\n'
        done

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-19 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Comprobando si Elastic search está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep elasticsearch_connector
        printf '\n'
        printf " Comprobando Search API Solr está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep search_api_solr

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-20 [AUTOMÁTICO]:${NC}\n"
        printf " El contenido más antigüo actualizado es del año: "
        CHANGEDDATA=$(vendor/bin/drush sql:query "SELECT changed FROM node_field_data ORDER BY changed ASC LIMIT 1")
        DATE=$(date -ud @${CHANGEDDATA} +%Y)
        printf ${DATE}
        if [[ ${DATE} < ${CONTENTOBS} ]]; then
          printf " ${RED}[KO]${NC}"
        else
          printf " ${GREEN}[OK]${NC}"
        fi
        printf '\n'
        printf " Hay usuarios que su último logeo es del año: "
        LASTLOG=$(vendor/bin/drush sql:query "SELECT access FROM users_field_data WHERE access > 0 ORDER BY access ASC LIMIT 1")
        DATE=$(date -ud @${LASTLOG} +%Y)
        printf ${DATE}
        if [[ ${DATE} < ${CONTENTOBS} ]]; then
          printf " ${RED}[KO]${NC}"
        else
          printf " ${GREEN}[OK]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-21 [MANUAL]:${NC}\n"
        printf " Esta tarea es totalmente manual. Por favor revise el contenido y campos para ver si se puede reutilizar en la medida de lo posible"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-22 [MANUAL]:${NC}\n"
        printf " El portal cuenta con los siguientes campos. Por favor revisa que no hay campos iguales con distintos nombres en distintas entidades y si se podrían unificar entidades\n\n"
        NODES=$(vendor/bin/drush eval "print_r(implode(' ', array_keys(\Drupal::service('entity_field.manager')->getFieldMap()['node'])));")
        NODES=(${NODES})
        IFS=$'\n' NODES=($(sort <<<"${NODES[*]}"))
        unset IFS
        PARAGRAPHS=$(vendor/bin/drush eval "print_r(implode(' ', array_keys(\Drupal::service('entity_field.manager')->getFieldMap()['paragraph'])));")
        PARAGRAPHS=(${PARAGRAPHS})
        IFS=$'\n' PARAGRAPHS=($(sort <<<"${PARAGRAPHS[*]}"))
        unset IFS
        TAXONOMIES=$(vendor/bin/drush eval "print_r(implode(' ', array_keys(\Drupal::service('entity_field.manager')->getFieldMap()['taxonomy_term'])));")
        TAXONOMIES=(${TAXONOMIES})
        IFS=$'\n' TAXONOMIES=($(sort <<<"${TAXONOMIES[*]}"))
        unset IFS
        # Create table
        COUNT=(${#NODES[@]} ${#PARAGRAPHS[@]} ${#TAXONOMIES[@]})
        IFS=$'\n'
        NCOUNT=$(echo "${COUNT[*]}" | sort -nr | head -n1)
        printf "NODES PARAGRAPHS TAXONOMIES \n" >> report-rev-drupal-22.txt
        printf "============ ============ ============ \n" >> report-rev-drupal-22.txt
        for (( i=0; i < $NCOUNT ; i=i+1 )); do
          printf "%1s %1s %1s\n" "${NODES[i]} ${PARAGRAPHS[i]} ${TAXONOMIES[i]}" >> report-rev-drupal-22.txt
        done
        cat report-rev-drupal-22.txt | column -t -s " "
        rm report-rev-drupal-22.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-23 [AUTOMÁTICO]:${NC}\n"
        printf " El CSS debería estar compactado:"
        AGREGATIONCSS=$(vendor/bin/drush cget system.performance css.preprocess)
        if [[ ${AGREGATIONCSS} == "'system.performance:css.preprocess': false" ]]; then
          printf "${RED}[KO]${NC}"
        else
          printf "${GREEN}[OK]${NC}"
        fi
        printf '\n'
        printf " El JS debería estar compactado:"
        AGREGATIONJS=$(vendor/bin/drush cget system.performance js.preprocess)
        if [[ ${AGREGATIONJS} == "'system.performance:js.preprocess': false" ]]; then
          printf "${RED}[KO]${NC}"
        else
          printf "${GREEN}[OK]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-24 [AUTOMÁTICO]:${NC}\n"
        printf " El caché debería estar habilitado:"
        CACHE=$(vendor/bin/drush cget system.performance page.cache.max_age)
        if [[ ${CACHE} == "'system.performance:page.cache.max_age': null" ]]; then
          printf "${RED}[KO]${NC}"
        else
          printf "${GREEN}[OK]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-25 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Comprobando si Redis está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep redis
        printf '\n'
        printf " Comprobando si Memcache está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep memcache
        printf '\n'
        printf " CDN: "
        curl --head --silent ${PROJECT_PRO_URL} >> curl.txt
        if [[ ! -z $(grep "X-Cache" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-26 [MANUAL]:${NC}\n"
        printf " Esta tarea es totalmente manual. Por favor revise si los módulos custom se han desarrollado de forma estandar, para que sean reutilizables en la medida de lo posible."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-27 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado los siguientes módulos custom con las siguientes nomenclaturas:\n"
        find web/modules/custom/. -maxdepth 1 -type d -printf '%f\n'

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-28 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado los siguientes módulos custom:\n"
        find "$(cd web/modules/custom; pwd -P)" -maxdepth 1 -type d
        printf '\n'
        printf " Se han encontrado los siguientes módulos custom con readme.md:\n"
        find "$(cd web/modules/custom; pwd -P)" -maxdepth 2 -iname "readme.md" -type f

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-29 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado los siguientes módulos que no deberían estar habilitados en PRO:\n"
        printf "Comprobando si Views UI está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep views_ui
        printf '\n'
        printf "Comprobando si Webform UI está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep webform_ui
        printf '\n'
        printf "Comprobando si Watchdog está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep watchdog
        printf '\n'
        printf "Comprobando si Page Manager UI está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep page_manager_ui
        printf '\n'
        printf " Se han encontrado los siguientes módulos contribuidos que estan deshabilitados (Revisar si se podrían eliminar):\n"
        vendor/bin/drush pm:list --type=module --no-core --status=disabled

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-30 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado las siguientes funciones deprecadas en los módulos custom:\n"
        composer require drupal/upgrade_status --no-interaction -q
        vendor/bin/drush en upgrade_status -y
        vendor/bin/drush us-a --all --ignore-contrib --skip-existing > report-rev-drupal-30.txt
        cat report-rev-drupal-30.txt | awk 'NR<=30'
        printf '\n\n'
        printf " Se ha generado un reporte completo en el fichero ${WORKDIR}/report-rev-drupal-30.txt"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-31 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado los siguientes módulos drupal/*, Por favor, comprueba que no existan módulos en versiones Dev:\n"
        composer show -i 'drupal/*'

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-32 [SEMIAUTOMÁTICO]:${NC}\n"
        if ! [ -x "$(command -v phpcs)" ]; then
          printf "${RED} PHPCS no esta installado.${NC} Por favor, para poder ejecutar este test, instale phpcs previamente.\n"
        else
          printf " A continuación se detalla el comando phpcs sobre los módulos custom:\n"
          phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md web/modules/custom > report-rev-drupal-32.txt
          cat report-rev-drupal-32.txt | awk 'NR<=20'
          printf '\n\n'
          printf " Se ha generado un reporte completo en el fichero ${WORKDIR}/report-rev-drupal-32.txt"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-33 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado los siguientes módulos custom:\n"
        find "$(cd web/modules/custom; pwd -P)" -maxdepth 1 -type d
        printf '\n'
        printf " Se han encontrado los siguientes tests:\n"
        find "$(cd web/modules/custom; pwd -P)" -maxdepth 2 -iname "tests" -type d

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-34 [MANUAL]:${NC}\n"
        printf " Esta tarea es totalmente manual. Por favor revise si los módulos custom podrían ser sustituidos por soluciones contribuidas."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-35 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se han encontrado los siguientes themes custom con las siguientes nomenclaturas:\n"
        find web/themes/custom/. -maxdepth 1 -type d -printf '%f\n'

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-36 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " A continuación se detalla el comando phpcs sobre los themes custom:\n"
        phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md web/themes/custom > report-rev-drupal-36.txt
        cat report-rev-drupal-36.txt | awk 'NR<=20'
        printf '\n\n'
        printf " Se ha generado un reporte completo en el fichero ${WORKDIR}/report-rev-drupal-36.txt"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-37 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Comprobando si Simple styleguide está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep simple_styleguide
        printf '\n'
        printf " Comprobando si Styleguide está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep styleguide

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-38 [MANUAL]:${NC}\n"
        printf " Cliente informa de que no se disponen de test visuales "
        printf "${RED}[KO]${NC}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DRUPAL-39 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Comprobar que los themes contribuidos están se encuentran en su última versión estable\n"
        composer outdated 'drupal/*'
        printf '\n\n'
        exit_script
        ;;
      "REV-DEVOPS")
        printf '\n'

        echo -e "${YELLOW}#######################################################################################${NC}\r"
        echo -e "${YELLOW}############################ REVISION DEVOPS (REV-DEVOPS) #############################${NC}\r"
        echo -e "${YELLOW}#######################################################################################${NC}\n"

        printf "${YELLOW} REV-DEVOPS-01 [AUTOMÁTICO]:${NC}\n"
        composer -V >> composer.txt
        printf " Se comprueba si existe composer: "
        if [[ ! -z $(grep "Composer version" "composer.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm composer.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-02 [AUTOMÁTICO]:${NC}\n"
        printf " Se comprueba si existe require-dev dentro del composer.json: "
        if [[ ! -z $(grep "require-dev" "composer.json") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-03 [AUTOMÁTICO]:${NC}\n"
        printf " Se comprueba si existe minimum-stability a dev dentro del composer.json: "
        if [[ ! -z $(grep '"minimum-stability": "dev"' "composer.json") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-04 [SEMIAUTOMÁTICO]:${NC}\n"
        if ! [ -x "$(command -v jq)" ]; then
          printf "${RED} JQ no esta installado.${NC} Por favor, para poder ejecutar este test, instale jq previamente.\n"
        else
          printf " Se han encontrado los siguientes patches en composer.json:\n"
          jq '.extra.patches' composer.json
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-05 [MANUAL]:${NC}\n"
        if ! [ -x "$(command -v jq)" ]; then
          printf "${RED} JQ no esta installado.${NC} Por favor, para poder ejecutar este test, instale jq previamente."
        else
          printf " Por favor, revisa cada uno de los scripts manualmente para ver cuales son sus funcionalidades:\n"
          jq '.scripts' composer.json
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-06 [AUTOMÁTICO]:${NC}\n"
        printf " Se comprueba si existe sort-packages a true dentro del composer.json: "
        if [[ ! -z $(grep '"sort-packages": true' "composer.json") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-07 [AUTOMÁTICO]:${NC}\n"
        if ! [ -x "$(command -v jq)" ]; then
          printf "${RED} JQ no esta installado.${NC} Por favor, para poder ejecutar este test, instale jq previamente.\n"
        else
          printf " Por favor, revisa que los installer-paths son correctos para la instalación de Drupal:\n"
          jq '.extra."installer-paths"' composer.json
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-08 [MANUAL]:${NC}\n"
        git config --get remote.origin.url >> git.txt
        printf " Se comprueba si existe git: "
        if [[ ! -z $(grep '/' "git.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm git.txt
        printf '\n\n'
        printf " Este proyecto cuenta con los siguientes submodules:\n"
        git config --file .gitmodules --name-only --get-regexp path
        printf '\n'
        printf " Por favor comprueba si algún módulo custom, podría ser reusable en distintos proyectos y tener su propio repositorio"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-09 [AUTOMÁTICO]:${NC}\n"
        GITURL=$(git config --get remote.origin.url)
        curl --head --silent ${GITURL} >> curl.txt
        printf " Se comprueba la URL de ${GITURL} y se verifica si hacemos ping (Solo se debería poder con VPN): "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${RED}[KO]${NC}"
        else
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${GITURL} 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-10 [MANUAL]:${NC}\n"
        printf " Por favor, revisa que se usan los estándares de Gitflow."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-11 [MANUAL]:${NC}\n"
        printf " Por favor, revisa que los siguen una nomenclatura estilo a 'IDTicket - Comment':\n\n"
        git log -n 20 --oneline

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-12 [MANUAL]:${NC}\n"
        printf " Por favor, contacte con cliente para saber si Git cuenta con distintos roles de usuarios que puedan aprobar PR y asegurar Gitflow."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-13 [MANUAL]:${NC}\n"
        printf " Por favor, acceda a la URL de GIT y compruebe que ramas estan como protected."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-14 [MANUAL]:${NC}\n"
        printf " Por favor, acceda a la URL de GIT y compruebe que existen al menos las ramas de dev, staging y master."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-15 [MANUAL]:${NC}\n"
        printf " Cliente informa de que no se disponen de dichos deploys: "
        printf "${RED}[KO]${NC}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-16 [MANUAL]:${NC}\n"
        printf " Por favor, revisa que se usan los estándares de Gitflow."

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-17 [MANUAL]:${NC}\n"
        printf " Cliente informa de que no se disponen de dichos WebHooks: "
        printf "${RED}[KO]${NC}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-18 [MANUAL]:${NC}\n"
        printf " Cliente informa de que no se disponen de dichos WebHooks: "
        printf "${RED}[KO]${NC}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-19 [MANUAL]:${NC}\n"
        printf " Cliente informa de que no se disponen de dichos WebHooks: "
        printf "${RED}[KO]${NC}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-20 [MANUAL]:${NC}\n"
        printf " Cliente informa de que si que se esta usando Jenkins como integración continua: "
        printf "${GREEN}[OK]${NC}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-DEVOPS-21 [AUTOMÁTICO]:${NC}\n"
        curl --head --silent ${JENKINSURL} >> curl.txt
        printf " Se comprueba la URL de ${JENKINSURL} y se verifica si hacemos ping (Solo se debería poder con VPN): "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${RED}[KO]${NC}"
        else
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I ${JENKINSURL} 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        fi
        rm curl.txt
        printf '\n\n'
        exit_script
        ;;
      "REV-INFRA")
        printf '\n'
        echo -e "${YELLOW}#######################################################################################${NC}\r"
        echo -e "${YELLOW}############################# REVISION INFRA (REV-INFRA) ##############################${NC}\r"
        echo -e "${YELLOW}#######################################################################################${NC}\n"

        printf "${YELLOW} REV-INFRA-01 [AUTOMÁTICO]:${NC}\n"
        cat /etc/os-release > release.txt
        printf " Se comprueba que los entornos cuentan con Debian/Linux/Rehat: "
        filename='release.txt'
        while read line; do
          if [[ "$line" == *"PRETTY_NAME="* ]]; then
            SYSTEM=${line/"PRETTY_NAME="/}
            if [[ "$SYSTEM" == *"Debian"*  ||  "$SYSTEM" == *"Linux"*  ||  "$SYSTEM" == *"Rehat"* ]]; then
              printf "${GREEN}[OK]${NC}"
            else
              printf "${RED}[KO]${NC}"
            fi
            printf '\n'
            printf " La versión del sistema operativo es: ${SYSTEM}"
          fi
        done < $filename
        rm release.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-02 [AUTOMÁTICO]:${NC}\n"
        php -v >> php.txt
        printf " Se comprueba si existe php: "
        if [[ ! -z $(grep "PHP" "php.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          filename='php.txt'
          n=0
          while read line; do
            if [[ "$n" == 0 ]]; then
              printf " La versión de php es: ${line} . Se recomienda que sea >= a ${PROJECT_PHP_VERSION_STABLE}"
            fi
            n=$(($n+1))
          done < $filename
          rm php.txt
        else
          printf "${RED}[KO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-03 [AUTOMÁTICO]:${NC}\n"
        MEMORYLIMIT=$(php -i | grep "memory_limit")
        MEMORY_LIMIT=${MEMORYLIMIT/"memory_limit => "/}
        printf " La variable límite de memoria en PHP es: ${MEMORY_LIMIT}"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-04 [AUTOMÁTICO]:${NC}\n"
        filename='curl.txt'
        curl -V >> $filename
        printf " Se comprueba si la librería CURL esta instalada: "
        if [[ ! -z $(grep "curl " "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          n=0
          while read line; do
            if [[ "$n" == 0 ]]; then
              printf " La versión de CURL es: ${line}.\n"
              printf " Se recomienda que sea la ultima version estable https://curl.se/download.htmls"
            fi
            n=$(($n+1))
          done < $filename
          rm $filename
        else
          printf "${RED}[KO]${NC}"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-05 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " Se comprueba la versión de Nginx/Apache:\n"
        if [[ $(ps -acx|grep apache|wc -l) > 0 ]]; then
          apachectl -v
          printf '\n'
          printf " Se recomienda instalar la última versión compatible estable: https://httpd.apache.org/download.cgi"
        fi
        if [[ $(ps -acx|grep nginx|wc -l) > 0 ]]; then
          nginx -v
          printf '\n'
          printf " Se recomienda instalar la última versión compatible estable: https://docs.nginx.com/nginx/releases/"
        fi

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-06 [AUTOMÁTICO]:${NC}\n"
        curl --head --silent "google.es" >> curl.txt
        printf " Se comprueba la URL de google.es y se verifica si hacemos ping: "
        if [[ ! -z $(grep "Date" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
          printf '\n'
          STATUS_CURL=$(curl -I "google.es" 2>&1 | awk '/HTTP\// {print $2}')
          printf " Status de la petición: ${STATUS_CURL}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-07 [AUTOMÁTICO]:${NC}\n"
        vendor/bin/drush dd files >> files.txt
        printf " Se comprueba que los ficheros estén en un entorno aparte (Por ejemplo Amazon S3): "
        if [[ ! -z $(grep "sites/default" "files.txt") ]]; then
          printf "${RED}[KO]${NC}"
          printf '\n'
          printf " Los ficheros estan alojados en: $(vendor/bin/drush dd files)"
        else
          printf "${GREEN}[OK]${NC}"
        fi
        rm files.txt

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-08 [AUTOMÁTICO]:${NC}\n"
        TEMP=$(vendor/bin/drush dd temp)
        printf " Se comprueba que los ficheros temporales estan en un directorio externo a Drupal: "
        if [[ "$TEMP" =~ .*"$WORKDIR".* ]]; then
          cd -P ${TEMP}
          ROOTTMP=$(pwd)
          if [[ "$ROOTTMP" =~ .*"$WORKDIR".* ]]; then
            printf "${RED}[KO]${NC}"
            printf '\n'
            printf " Estan alojados en: $($WORKDIR/vendor/bin/drush dd temp)"
          else
            printf "${GREEN}[OK]${NC}"
            printf '\n'
            printf " Estan alojados en: ${ROOTTMP}"
          fi
        else
          printf "${GREEN}[OK]${NC}"
        fi
        cd ${WORKDIR}

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-09 [MANUAL]:${NC}\n"
        printf " Compruebe los permisos de ficheros y carpetas. Los ficheros alojados dentro de $WORKDIR/web/sites/default son:\n"
        ls -la ${WORKDIR}/web/sites/default

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-10 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " El driver de base de datos usado es: $(vendor/bin/drush core-status --field=db-driver)"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-11 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " La versión de mysql es: $(mysql --version). La version mínima para mariadB debería ser 10.3.7 y para mysql la 5.7.8"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-12 [SEMIAUTOMÁTICO]:${NC}\n"
        printf " La versión de Drush es: $(vendor/bin/drush core-status --field=drush-version). Se recomienda el uso de Drush 11"

        printf "\n\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
        printf "${YELLOW} REV-INFRA-13 [SEMIAUTOMÁTICO]:${NC}\n"
        printf "Comprobando si Redis está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep redis
        printf '\n'
        printf "Comprobando si Memcache está instalado:\n"
        vendor/bin/drush pm:list --type=module --status=enabled | grep memcache
        printf '\n'
        printf "CDN: "
        curl --head --silent ${PROJECT_PRO_URL} >> curl.txt
        if [[ ! -z $(grep "X-Cache" "curl.txt") ]]; then
          printf "${GREEN}[OK]${NC}"
        else
          printf "${RED}[KO]${NC}"
        fi
        rm curl.txt
        printf '\n\n'
        exit_script
        ;;
      "Salir")
        exit_script
        ;;
      *) echo -e "\n\n ${RED}Opción no valida${NC}\n\n";;
    esac
  }

  ##############################################################################
  ################### SCRIPT QUESTION/EXECUTION WITH PARAMETER #################
  ##############################################################################
  # Set initial configuration.
  script_configuration
  options=("REV-DRUPAL" "REV-DEVOPS" "REV-INFRA" "Salir")
  if [[ -z "$1" ]]; then
    printf "\n${YELLOW}----------------------------------------------------------------------------${NC}\n"
    printf "${YELLOW} SELECCIONA QUE TEST QUIERES EJECUTAR:${NC}\n\n"
    PS3=" SELECCIONA EL Nº: "
    select opt in "${options[@]}"
    do
      let VALUE_PARAM=$REPLY-1
      PARAMETER=${options[$VALUE_PARAM]}
      # Run 'auditoria' script.
      script_execution ${PARAMETER}
    done
  else
    let VALUE_PARAM=$1-1
    PARAMETER=${options[$VALUE_PARAM]}
    # Run 'auditoria' script.
    script_execution ${PARAMETER}
  fi
else
  printf '\n\n'
  exit_script 1
fi
