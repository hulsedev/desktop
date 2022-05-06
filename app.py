import webbrowser
import time

import os
import hulse
import requests
import rumps

import utils

rumps.debug_mode(True)

LOGIN_URL = "https://hulse-api.herokuapp.com/login"
VALIDATE_URL = "https://hulse-api.herokuapp.com/ping"  # "http://localhost:8000/ping"  #
HULSE_ICON = "hulse_nunito_white.png"
SETTINGS_URL = "https://dashboard.hulse.app"  # "http://localhost:8000"  #
HULSE_API_KEY = None

# initialize login window
login_window = rumps.Window(
    message="Enter your Hulse API key below to login to your account.",
    title="Login to Hulse",
    cancel="Cancel",
    ok="Submit",
    dimensions=(300, 60),
)
login_window.add_button(
    "No account yet? Create one here",
)
login_window.icon = HULSE_ICON
host_thread = None


def validate_api_key(api_key):
    resp = requests.get(VALIDATE_URL, headers=hulse.settings.get_auth_headers(api_key))
    if resp.status_code != 200:
        return False

    return True


def login(_):
    """Prompt user for login credentials (API key) or redirect towards signup page."""
    global HULSE_API_KEY
    window_response = login_window.run()
    if window_response.clicked == 1 and validate_api_key(window_response.text):
        # post a request to the server to check if api key is valid
        HULSE_API_KEY = window_response.text
        rumps.notification(
            title="Successfully logged in!",
            subtitle="Your API key was successfully validated.",
            message="",
        )
        start_host_item.set_callback(start_host)
        settings_item.set_callback(settings)
        login_item.set_callback(None)
    elif window_response.clicked == 2:
        webbrowser.open_new(LOGIN_URL)
    else:
        pass


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
