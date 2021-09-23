#!/bin/bash

set -e

# Read utility functions
UTIL_SCRIPT=util.sh
. ${UTIL_SCRIPT}

#Local switches
RDS_DB_HOST=${1:$PROJECT_NAME.$DEF_HOST_SFX}
RDS_DB_PASS_PATH=${2:-$DEF_RDS_PASS_PATH}
UTIL_SCRIPT=util.sh


PROJECT_DIR=${SCRIPT_DIR}/${PROJECT_NAME}



usage () {
    echo "Usage: ./meta.sh <rds-db-host> <pwd-path>"
    echo "   RDS database host name"
    echo "   pwd: <db-user> password or the location of the file where it is stored"
}

if [[ $1 == *"help"* ]]; then
    usage
    exit
fi

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap finally EXIT



create_secrets (){
    read_refs
    
    RDS_DB_PASS=$(head -n 1 $RDS_DB_PASS_PATH);
    
    echo !!! kubectl create secret generic metatrino-secret \
    --from-literal=rds-pg-host=${RDS_DB_HOST} \
    --from-literal=rds-pg-name=${RDS_DB_NAME} \
    --from-literal=rds-pg-user=${RDS_DB_USER} \
    --from-literal=rds-pg-pass=${RDS_DB_PASS}
    
    read_creds

    echo !!! kubectl create secret generic s3-vibrant-dragon \
    --from-literal=id=${aws_access_key_id} \
    --from-literal=secret=${aws_secret_access_key}
}
install () {
    echo !!! "helm install ${PROJECT_NAME} ${SCRIPT_DIR}/${PROJECT_NAME}"
}

uninstall () {
    echo !!! "helm uninstall ${PROJECT_NAME}"
}

create_secrets
install
uninstall

echo 