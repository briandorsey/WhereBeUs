import types
from django.conf import settings
from django.http import Http404, HttpResponseForbidden
from google.appengine.ext import db
from google.appengine.api import users
from google.appengine.api import memcache
from .utils import method_not_allowed

def _requires_method(view_function, method):
    def wrapper(request, *args, **kwargs):
        if request.method != method:
            return method_not_allowed("Must be called with %s." % method)
        return view_function(request, *args, **kwargs)
    wrapper.__name__ = view_function.__name__
    wrapper.__module__ = view_function.__module__
    return wrapper

def requires_GET(view_function):
    return _requires_method(view_function, method = "GET")
    
def requires_POST(view_function):
    return _requires_method(view_function, method = "POST")

def requires_google_admin_login(view_function):
    def wrapper(request, *args, **kwargs):
        if not users.is_current_user_admin():
            return HttpResponseForbidden()
        else:
            return view_function(request, *args, **kwargs)
    wrapper.__name__ = view_function.__name__
    wrapper.__module__ = view_function.__module__
    return wrapper
