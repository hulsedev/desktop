#!/bin/bash
export $(cat .env | xargs)

archs=("arm64" "x86_64" "universal2")
echo "Building for architectures: ${archs}"

for arch in ${archs[*]}; do
    #echo "Building for architecture: ${arch}"
    #python3 setup.py py2app --bdist-base=build/$arch --dist-dir=dist/$arch --arch=$arch
    
    echo "Signing app for ${arch}"
    codesign -s $DEV_ID -v --deep --timestamp --entitlements entitlements.plist -o runtime "dist/${arch}/Hulse.app"
    
    echo "Creating disk image for app for ${arch}"
    # make sure that the dmg file is not already there
    test -f dist/$arch/Hulse.dmg && rm dist/$arch/Hulse.dmg
    appdmg "config/dmg/${arch}.json" dist/$arch/Hulse.dmg
    
    echo "Signing disk image for ${arch}"
    codesign -s $DEV_ID -v --deep --timestamp --entitlements entitlements.plist -o runtime "dist/${arch}/Hulse.dmg"

    echo "Notarizing app for ${arch}"
    xcrun notarytool submit dist/$arch/Hulse.dmg --keychain-profile "hulse-desktop-app" --wait 
    
    echo "Stapling app for ${arch}"
    xcrun stapler staple dist/$arch/Hulse.app

    echo "DONE! for ${arch}"
done