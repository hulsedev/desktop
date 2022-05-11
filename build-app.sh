python3 setup.py py2app --bdist-base=build/arm64 --dist-dir=dist/arm64 --arch=arm64
python3 setup.py py2app --bdist-base=build/x86_64 --dist-dir=dist/x86_64 --arch=x86_64
python3 setup.py py2app --bdist-base=build/universal2 --dist-dir=dist/universal2 --arch=universal2