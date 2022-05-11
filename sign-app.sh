#!/bin/bash
#export $(grep -v '^#' .env | xargs)

# DIY tentative at signing the app, go see signbuild.sh
DEV_ID="Developer ID Application: SACHA, ROBERT, JEAN LÉVY (3HVS63DY22)"
archs=("x86_64" "universal2" "arm64")
echo "Building for architectures: ${archs[*]}"

for arch in ${archs[*]}; do
    echo "Building for architecture: ${arch}"
    python3 setup.py py2app --bdist-base=build/$arch --dist-dir=dist/$arch --arch=$arch
    
    echo "Signing app for ${arch}"
    codesign -s "${DEV_ID}" --force --verbose --timestamp --entitlements entitlements.plist -o runtime "dist/${arch}/Hulse.app"
    if codesign -dvv --deep dist/$arch/Hulse.app 2>&1 | grep -qF "Authority=${DEV_ID}"
    then
        echo "Hulse app for ${arch} is correctly signed!"
    else
        echo "Error Hulse app for ${arch} is not signed!"
        exit 1
    fi

    echo "Creating disk image for app for ${arch}"
    # make sure that the dmg file is not already there
    test -f dist/$arch/Hulse.dmg && rm dist/$arch/Hulse.dmg
    appdmg "config/dmg/${arch}.json" "dist/${arch}/Hulse.dmg"
    
    echo "Signing disk image for ${arch}"
    codesign -s "${DEV_ID}" -v --deep --timestamp --entitlements entitlements.plist -o runtime "dist/${arch}/Hulse.dmg"
    if codesign -dvv --deep dist/$arch/Hulse.dmg 2>&1 | grep -qF "Authority=${DEV_ID}"
    then
        echo "Hulse dmg for ${arch} is correctly signed!"
    else
        echo "Error Hulse dmg for ${arch} is not signed!"
        exit 1
    fi

    echo "Notarizing app for ${arch}"
    xcrun notarytool submit dist/$arch/Hulse.dmg --keychain-profile "hulse-desktop-app" --wait 
    
    echo "Stapling app for ${arch}"
    xcrun stapler staple dist/$arch/Hulse.app

    echo "DONE! for ${arch}"
done