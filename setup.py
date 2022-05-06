"""
This is a setup.py script generated by py2applet

Usage:
    python setup.py py2app
"""

from setuptools import setup

APP = ["app.py"]
DATA_FILES = ["hulse_nunito_white.png"]
OPTIONS = {
    "argv_emulation": True,
    "iconfile": "hulse_nunito_white.png",
    "plist": {
        "CFBundleShortVersionString": "0.2.0",
        "LSUIElement": True,
    },
    "packages": ["rumps", "py2app", "requests"],
}

setup(
    app=APP,
    name="Hulse",
    data_files=DATA_FILES,
    options={"py2app": OPTIONS},
    setup_requires=["py2app"],
    install_requires=["rumps"],
)
