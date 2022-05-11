    #!/usr/bin/env bash

#
#  assumes Xcode 13 is installed
#  assumes I added an entry APP_PASSWORD to my keychain
#
notarizationId=$1

if [ -z $notarizationId ]; then
        echo "Provide a notarization id"
        exit
fi

clear
xcrun notarytool log $notarizationId --keychain-profile "hulse-desktop-app" "notary-${notarizationId}.log"
