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

export LOGFILE="CodeSigning.log"
#
# PyGitIssueClone.app/Contents/Frameworks/liblzma.5.dylib: main executable failed strict validation
echo "Manually copy from: /usr/local/Cellar/xz/5.2.5/lib/liblzma.5.dylib"
# https://stackoverflow.com/questions/62095338/py2app-fails-macos-signing-on-liblzma-5-dylib
#
export GOOD_LIB='/usr/local/Cellar/xz/5.2.5/lib/liblzma.5.dylib'
export DIR_TO_OVER_WRITE="${FULL_APP_NAME}/Contents/Frameworks"

# echo "GOOD_LIB: ${GOOD_LIB}"
# echo "DIR_TO_OVER_WRITE: ${DIR_TO_OVER_WRITE}"
cp -vp ${GOOD_LIB} ${DIR_TO_OVER_WRITE}
#
#  Ugh code signing will be the death of me
#
rm -vrf ${FULL_APP_NAME}/Contents/Resources/lib/python3.9/todoist/.DS_Store
rm -vrf ${FULL_APP_NAME}/Contents/Resources/lib/python3.9/numpy/f2py/tests/src/assumed_shape/.f2py_f2cmap

# deleting template using old sdks
rm -vrf ${FULL_APP_NAME}/Contents/Resources/lib/python3.9/py2app/bundletemplate/prebuilt/main-i386
rm -vrf ${FULL_APP_NAME}/Contents/Resources/lib/python3.9/py2app/bundletemplate/prebuilt/main-intel
#
# This is a real certificate - expires 21 September 2026
#
export IDENTITY="Developer ID Application: SACHA, ROBERT, JEAN LÉVY (3HVS63DY22)"
export OPTIONS="--verbose --force --timestamp --options=runtime "
#
#  assumes Xcode 13 is installed
#
echo "Sign frameworks"
echo "" > ${LOGFILE}
codesign --sign "${IDENTITY}" ${OPTIONS} "${FULL_APP_NAME}/Contents/Frameworks/Python.framework/Versions/3.9/Python" >> ${LOGFILE} 2>&1

echo "Sign libraries"

find "${FULL_APP_NAME}" -iname '*.so' -or -iname '*.dylib' |
    while read libfile; do
        codesign --sign "${IDENTITY}" ${OPTIONS} "${libfile}" >> ${LOGFILE} 2>&1 ;
    done;

# sign all binary app templates from py2app
echo "Sign py2app app template binaries"
find "${FULL_APP_NAME}/Contents/Resources/lib/python3.9/py2app/apptemplate/prebuilt" |
    while read libfile; do
        codesign --sign "${IDENTITY}" ${OPTIONS} "${libfile}" >> ${LOGFILE} 2>&1 ;
    done;

echo "Sign py2app bundle template binaries"
find "${FULL_APP_NAME}/Contents/Resources/lib/python3.9/py2app/bundletemplate/prebuilt" |
    while read libfile; do
        codesign --sign "${IDENTITY}" ${OPTIONS} "${libfile}" >> ${LOGFILE} 2>&1 ;
    done;

# sign all torch bin executables
echo "Sign torch binaries"
find "${FULL_APP_NAME}/Contents/Resources/lib/python3.9/torch/bin" |
    while read libfile; do
        codesign --sign "${IDENTITY}" ${OPTIONS} "${libfile}" >> ${LOGFILE} 2>&1 ;
    done;


codesign --sign "${IDENTITY}" ${OPTIONS} "${FULL_APP_NAME}/Contents/MacOS/python"               >> ${LOGFILE} 2>&1
codesign --sign "${IDENTITY}" ${OPTIONS} "${FULL_APP_NAME}/Contents/MacOS/${APPLICATION_NAME}"  >> ${LOGFILE} 2>&1
