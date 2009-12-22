import logging
from django.conf import settings
from .securedictionary import serialize_dictionary, deserialize_dictionary

SESSION_COOKIE_KEY = "_session"
USER_KEY_SESSION_KEY = "_user_key"

class AppEngineSecureSessionMiddleware(object):
    def process_request(self, request):
        def get_session(name, default=None):
            return request._session.get(name, default)
        
        def set_session(name, value):
            request._session[name] = value
            request._session_dirty = True
            
        def del_session(name):
            del request._session[name]
            request._session_dirty = True
            
        def session_has(name):
            return name in request._session
        
        session_value = request.COOKIES.get(SESSION_COOKIE_KEY, None)
        if session_value is not None:
            request._session = deserialize_dictionary(session_value)
            if request._session is None:
                request._session = {}
        else:
            request._session = {}
        request._session_dirty = False
        setattr(request, 'get_session', get_session)
        setattr(request, 'set_session', set_session)
        setattr(request, 'del_session', del_session)
        setattr(request, 'session_has', session_has)
        
        # Debug only -- logs content of sessions. Useful, perhaps.
        if settings.DEBUG_SESSIONS:
            debug_info = "\n\n\n*** INCOMING SESSION CONTENTS:"
            for k, v in request._session.iteritems():
                debug_info += "\n***\t%s = %r" % (k, v)
            debug_info += "\n\n"
            logging.info(debug_info)
                
    def process_response(self, request, response):
        if hasattr(request, '_session_dirty') and request._session_dirty:
            response.set_cookie(SESSION_COOKIE_KEY, serialize_dictionary(request._session))
            
            # Debug only -- logs content of sessions. Useful, perhaps.
            if settings.DEBUG_SESSIONS:
                debug_info = "\n\n\n*** CHANGED, OUTGOING SESSION CONTENTS:"
                for k, v in request._session.iteritems():
                    debug_info += "\n***\t%s = %r" % (k, v)
                debug_info += "\n\n"
                logging.info(debug_info)
            
        return response
        
class AppEngineGenericUserMiddleware(object):
    def process_request(self, request):
        user_key = request.get_session(USER_KEY_SESSION_KEY)
        if user_key:
            request.user = User.get(user_key)
        else:
            request.user = None
        request._original_user = request.user            
        
    def process_response(self, request, response):
        if request._original_user != request.user:
            if request.user is None:
                request.del_session(USER_KEY_SESSION_KEY)
            else:
                request.set_session(USER_KEY_SESSION_KEY, request.user.key())
        return response
        
        