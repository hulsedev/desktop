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

export APP="${APPLICATION_NAME}.app"

FULL_PROJECT_DIR="${PROJECTS_BASE}/${PROJECT_DIR}"
FULL_APP_NAME="${FULL_PROJECT_DIR}/dist/${ARCH}/${APP}"


export APP_PATH="${FULL_APP_NAME}"
export ZIP_PATH="${FULL_PROJECT_DIR}/dist/${ARCH}/$APPLICATION_NAME.zip"
export DMG_PATH="${FULL_PROJECT_DIR}/dist/${ARCH}/$APPLICATION_NAME.dmg"

echo "${txReverse}Clean up in case of restart on failure${txReset}"
rm -rfv "${ZIP_PATH}"
rm -rfv "${DMG_PATH}"

echo "${txReverse}Create a ZIP archive suitable for notarization${txReset}"
/usr/bin/ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"

echo "${txReverse}Create a DMG suitable for notarization${txReset}"
appdmg "${FULL_PROJECT_DIR}/config/dmg/${ARCH}.json" "${DMG_PATH}"

#
#  assumes Xcode 13 is installed
#  assumes you added an entry APP_PASSWORD to your keychain
#
echo "${txReverse}Call Apple for notary service${txReset}"
xcrun notarytool submit "${ZIP_PATH}" --keychain-profile "hulse-desktop-app" --wait
echo "${txReverse}Call Apple for notary service${txReset}"
xcrun notarytool submit "${DMG_PATH}" --keychain-profile "hulse-desktop-app" --wait