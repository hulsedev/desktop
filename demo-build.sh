python3 setup.py py2app --bdist-base=demo/build/ --dist-dir=demo/dist/ --arch=x86_64
appdmg "config/dmg/demo.json" "demo/dist/Hulse.dmg"
