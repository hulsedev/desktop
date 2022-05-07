import inspect
import os
import ctypes
import threading

from flask import Flask, redirect, render_template, request, session, url_for


def _async_raise(tid, exctype):
    """Raises an exception in the threads with id tid"""
    # https://stackoverflow.com/a/325528
    if not inspect.isclass(exctype):
        raise TypeError("Only types can be raised (not instances)")
    res = ctypes.pythonapi.PyThreadState_SetAsyncExc(
        ctypes.c_long(tid), ctypes.py_object(exctype)
    )
    if res == 0:
        raise ValueError("invalid thread id")
    elif res != 1:
        # "if it returns a number greater than one, you're in trouble,
        # and you should call it again with exc=NULL to revert the effect"
        ctypes.pythonapi.PyThreadState_SetAsyncExc(ctypes.c_long(tid), None)
        raise SystemError("PyThreadState_SetAsyncExc failed")


class HostThread(threading.Thread):
    def _get_my_tid(self):
        if not self.is_alive():
            raise threading.ThreadError("the thread is not active")

        # do we have it cached?
        if hasattr(self, "_thread_id"):
            return self._thread_id

        # no, look for it in the _active dict
        for tid, tobj in threading._active.items():
            if tobj is self:
                self._thread_id = tid
                return tid

        raise AssertionError("could not determine the thread's id")

    def raise_exception(self, exctype):
        _async_raise(self._get_my_tid(), exctype)


class LoginThread(HostThread):
    def __init__(
        self, group=None, target=None, name=None, args=(), kwargs={}, *, daemon=None
    ):
        super().__init__(
            group=group,
            target=target,
            name=name,
            args=args,
            kwargs=kwargs,
            daemon=daemon,
        )
        self.api_key = None

        self.app = Flask(__name__)
        self.app.secret_key = os.getenv("SECRET_KEY", "mysecretkey")

        @self.app.route("/")
        def home():
            self.api_key = request.args.get("authToken")
            return redirect("https://www.hulse.app/success")

    def run(self):
        try:
            self.app.run(host="0.0.0.0", port=4240)
        except Exception as e:
            print("handled exception here")
            return True
        return False

    def get_api_key(self):
        return self.api_key
