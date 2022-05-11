# debug signing & notarization process for demo app
PROJECT_BASE="/Users/sachalevy/implement"
PROJECT_DIR="hulse-desktop"
APPLICATION_NAME="Hulse"
DEV_ID="Developer ID Application: SACHA, ROBERT, JEAN LÉVY (3HVS63DY22)"
arch=""

bash scripts/python39zipsign.sh $PROJECT_DIR $APPLICATION_NAME $arch