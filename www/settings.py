import os
import datetime

RUNNING_APP_ENGINE_LOCAL_SERVER = os.environ.get('SERVER_SOFTWARE', 'Dev').startswith('Dev')

DEBUG = RUNNING_APP_ENGINE_LOCAL_SERVER # For now

TIME_HORIZON = datetime.timedelta(hours = 2)

APPEND_SLASH = True

INSTALLED_APPS = ['wherebeus']

MIDDLEWARE_CLASSES = [
    'django.middleware.common.CommonMiddleware',
    'django.middleware.http.ConditionalGetMiddleware',
    'wherebeus.middleware.AppEngineSecureSessionMiddleware',
]

DEBUG_SESSIONS = False # Set to True to get log lines about the contents of the session object

ROOT_URLCONF = 'urls'

TEMPLATE_CONTEXT_PROCESSORS = [] 

TEMPLATE_DEBUG = DEBUG

TEMPLATE_DIRS = [os.path.join(os.path.dirname(__file__), 'templates')]

TEMPLATE_LOADERS = ['django.template.loaders.filesystem.load_template_source']

FILE_UPLOAD_HANDLERS = ['django.core.files.uploadhandler.MemoryFileUploadHandler']

FILE_UPLOAD_MAX_MEMORY_SIZE = 10485760 # 10 MB -- an appengine maximum

SERIALIZATION_SECRET_KEY = '\xcfB\xf6\xb9\xc4\xe4\xfa\x07\x8atE\xdc\xec\xf9zaR\xa4\x13\x88'

LOGIN_URL = "/login/"

REDIRECT_FIELD_NAME = "redirect_url"

# only use local_settings.py if we're running debug server
if RUNNING_APP_ENGINE_LOCAL_SERVER:
    try:
        from local_settings import *
    except ImportError, exp:
        pass
