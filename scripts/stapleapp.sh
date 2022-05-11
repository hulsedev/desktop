
tput clear
source ./scripts/common.sh
setProjectsBase

PROJECT_DIR=${1}
APPLICATION_NAME=${2}
ARCH=${3}

export APP="${APPLICATION_NAME}.app"

FULL_PROJECT_DIR="${PROJECTS_BASE}/${PROJECT_DIR}"
FULL_APP_NAME="${FULL_PROJECT_DIR}/dist/${ARCH}/${APP}"

#
#  assumes Xcode 13 is installed
#
echo "${txReverse}Start stapling: ${FULL_APP_NAME}${txReset}"
xcrun stapler staple ${FULL_APP_NAME}
