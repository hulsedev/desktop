import http.server
import os
import time
import webbrowser
from urllib.parse import quote_plus, urlencode

import hulse
import requests
import rumps
from dotenv import load_dotenv
from flask import Flask, redirect, render_template, request, session, url_for

import utils

load_dotenv()
rumps.debug_mode(True)

LOGIN_URL = os.getenv(
    "LOGIN_URL", "https://hulse-api.herokuapp.com/login/?source=desktop"
)
VALIDATE_URL = os.getenv(
    "VALIDATE_URL", "https://hulse-api.herokuapp.com/ping"
)  # "http://localhost:8000/ping"  #
HULSE_ICON = "hulse_nunito_white.png"
SETTINGS_URL = os.getenv(
    "SETTINGS_URL", "https://dashboard.hulse.app"
)  # "http://localhost:8000"  #
HULSE_API_KEY = None

AUTH0_DOMAIN = "dev-le9leu4t.us.auth0.com"
AUTH0_CLIENT_ID = "pO7VIcgQe7kyrMZXyN8vOsLOoqgokBgR"

host_thread = None


def validate_api_key(api_key):
    resp = requests.get(VALIDATE_URL, headers=hulse.settings.get_auth_headers(api_key))
    if resp.status_code != 200:
        return False

    return True


def authenticate_user(hulse_login_url):
    global HULSE_API_KEY
    login_thread = utils.LoginThread()
    login_thread.start()
    # start local server to handle authentication
    webbrowser.open_new(hulse_login_url)
    # retrieve the api key upon finishing login
    while not login_thread.get_api_key():
        time.sleep(0.1)

    print("got an Hulse API key")
    return login_thread.get_api_key(), login_thread


def login(_):
    """Prompt user for login credentials (API key) or redirect towards signup page."""
    global HULSE_API_KEY
    # run the authentication using auth0
    api_key, login_thread = authenticate_user(LOGIN_URL)
    if api_key and login_thread:
        # stop login server
        login_thread.raise_exception(SystemExit)
        login_thread.join()

        # acknowledge login on app
        HULSE_API_KEY = api_key
        rumps.notification(
            title="Successfully logged in!",
            subtitle="Your API key was successfully validated.",
            message="",
        )
        start_host_item.set_callback(start_host)
        settings_item.set_callback(settings)
        login_item.set_callback(None)


def start_host(_):
    """Start the Hulse host."""
    global host_thread

    start_host_item.set_callback(None)
    stop_host_item.set_callback(stop_host)

    # start a background process to run the Hulse host
    host_thread = utils.HostThread(
        target=hulse.utils.run_host, args=(HULSE_API_KEY,), name="host", daemon=True
    )
    host_thread.start()


def stop_host(_):
    """Stop the currently running Hulse Host."""
    global host_thread

    start_host_item.set_callback(start_host)
    stop_host_item.set_callback(None)

    if not host_thread:
        raise RuntimeError("No Hulse host is running.")

    # kill the thread is still active
    print("raising exception")
    host_thread.raise_exception(SystemExit)
    print("completed raising exception")
    host_thread.join()
    print("completed joining thread")
    host_thread = None


def settings(_):
    """Redirect towards settings page (admin webapp)."""
    webbrowser.open_new(SETTINGS_URL)


app = rumps.App("Hulse", quit_button=rumps.MenuItem("Quit Hulse", key="q"))
login_item = rumps.MenuItem(title="Login", callback=login)
start_host_item = rumps.MenuItem(title="Start host", callback=None)
stop_host_item = rumps.MenuItem(title="Stop host", callback=None)
settings_item = rumps.MenuItem(title="Settings", callback=None)
app.menu = [login_item, start_host_item, stop_host_item, settings_item]

app.icon = HULSE_ICON
app.template = True
app.run()
