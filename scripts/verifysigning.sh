#!/usr/bin/env bash

tput clear
source ./scripts/common.sh
setProjectsBase

PROJECT_DIR=${1}
APPLICATION_NAME=${2}
ARCH=${3}
# If either of the parameters do not exist the function will
# print an error messaged and exit the script with a non-zero 
# status code
validateParameters ${PROJECT_DIR} ${APPLICATION_NAME} ${ARCH}


printf "Working on project: ${txReverse}${PROJECT_DIR}${txReset}\n"
printf "Application ${txReverse}${APPLICATION_NAME}${txReset}\n"

FULL_PROJECT_DIR="${PROJECTS_BASE}/${PROJECT_DIR}"
FULL_APP_NAME="${FULL_PROJECT_DIR}/dist/${ARCH}/${APPLICATION_NAME}.app"
#
#  assumes Xcode 13 is installed
#
spctl -vvvv --assess --type exec "${FULL_APP_NAME}"
