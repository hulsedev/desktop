PROJECT_BASE="/Users/sachalevy/implement"
PROJECT_DIR="hulse-desktop"
APPLICATION_NAME="Hulse"
DEV_ID="Developer ID Application: SACHA, ROBERT, JEAN LÉVY (3HVS63DY22)"
archs=("x86_64" "universal2" "arm64")
echo "Building for architectures: ${archs[*]}"
echo "Removing current build & dist folders"
rm -rf build/ && rm -rf dist/

for arch in ${archs[*]}; do
    echo "Building for architecture: ${arch}"
    python3 setup.py py2app --bdist-base=build/$arch --dist-dir=dist/$arch --arch=$arch
    echo "Preparing app for distribution for ${arch}"
    bash scripts/python39zipsign.sh $PROJECT_DIR $APPLICATION_NAME $arch
    bash scripts/signapp.sh $PROJECT_DIR $APPLICATION_NAME $arch
    exit 1
    bash scripts/notarizeapp.sh $PROJECT_DIR $APPLICATION_NAME $arch
    bash scripts/stapleapp.sh $PROJECT_DIR $APPLICATION_NAME $arch
    bash scripts/verifysigning.sh $PROJECT_DIR $APPLICATION_NAME $arch
done