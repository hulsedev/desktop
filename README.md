# Hulse Desktop App
This repository contains the code for the Hulse desktop app. 

## Producing a new release
Follow these steps to generate a new release of the app:
```bash
# run py2app and update the dist package with latest code
python3 setup.py py2app 
# optionally remove the current dmg file
rm Hulse.dmg
# run dmg maker
appdmg dmg-config.json Hulse.dmg
```

Then go to AWS bucket for Hulse desktop and upload the newest version of the app there.