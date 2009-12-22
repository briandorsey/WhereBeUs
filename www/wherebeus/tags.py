import django.template as djangot
from django.conf import settings
from google.appengine.ext.webapp import template
from django.template.loader import get_template as djangot_get_template
from django.template import Context as djangot_Context
from django.core.urlresolvers import reverse
from google.appengine.api import users

register = template.create_template_register()


#------------------------------------------------------------------------------
# Helpers
#------------------------------------------------------------------------------

def _resolve_variable_or_expression(v_or_e, context):
    value = None

    # Try it as a variable first            
    try:
        variable = djangot.Variable(v_or_e)
        value = variable.resolve(context)
    except Exception:   # Not sure what to catch here, but make sure we don't catch AppEngine's DeadlineExceededException.
        value = None

    # And as an actual python value second
    if value is None:
        try:
            value = eval(v_or_e)
        except Exception:
            value = None
            
    return value


#------------------------------------------------------------------------------
# "Static URLs."
#------------------------------------------------------------------------------

# Pointer to static media _for our site_ (like our js/css/images)
@register.tag(name="static_url")
def static_url(parser, token):
    try:
        tag_name, relative_path = token.split_contents()
    except ValueError:
        raise djangot.TemplateSyntaxError, "static_url tag expects a relative path (like /css/foo.css)"
    return StaticUrlNode(relative_path)

class StaticUrlNode(djangot.Node):
    def __init__(self, relative_path):
        self.relative_path = relative_path

    def render(self, context):
        return self.relative_path


#------------------------------------------------------------------------------
# Current User is Google Admin?
#------------------------------------------------------------------------------

@register.tag(name="if_user_is_google_admin")
def if_user_is_google_admin(parser, token):
    nodelist = parser.parse(('end_if_user_is_google_admin',))
    parser.delete_first_token()
    return IfUserIsGoogleAdminNode(nodelist)

class IfUserIsGoogleAdminNode(djangot.Node):
    def __init__(self, nodelist):
        self.nodelist = nodelist

    def render(self, context):
        if users.is_current_user_admin():
            return self.nodelist.render(context)
        else:
            return ""


#------------------------------------------------------------------------------
# "Django Debug" -- an if statement that is true if we're on debug mode
#------------------------------------------------------------------------------

@register.tag(name="if_django_debug")
def if_django_debug(parser, token):
    nodelist = parser.parse(('end_if_django_debug',))
    parser.delete_first_token()
    return IfDjangoDebugNode(nodelist)

class IfDjangoDebugNode(djangot.Node):
    def __init__(self, nodelist):
        self.nodelist = nodelist
        
    def render(self, context):
        if settings.DEBUG:
            return self.nodelist.render(context)
        else:
            return ""


#------------------------------------------------------------------------------
# "Django NOT Debug" -- an if statement that is true if we're on debug mode
#------------------------------------------------------------------------------

@register.tag(name="if_not_django_debug")
def if_not_django_debug(parser, token):
    nodelist = parser.parse(('end_if_not_django_debug',))
    parser.delete_first_token()
    return IfNotDjangoDebugNode(nodelist)

class IfNotDjangoDebugNode(djangot.Node):
    def __init__(self, nodelist):
        self.nodelist = nodelist

    def render(self, context):
        if not settings.DEBUG:
            return self.nodelist.render(context)
        else:
            return ""


#------------------------------------------------------------------------------
# "Partial" template; currently VERY HACKNOLOGICAL, but it works. Should be hella cleaned.
#------------------------------------------------------------------------------

# NOTE WELL -- THIS CODE IS HACKNOLOGY -- have been meaning to clean it up.

@register.tag(name="partial")
def partial(parser, token):
    try:
        contents = token.split_contents()
        template_path = contents[1].strip()
        if template_path[0] in '"\'':
            template_path = template_path[1:-1]
        dictionary_string = ' '.join(contents[2:])
        dictionary_info = parse_dictionary_string(dictionary_string)
    except djangot.TemplateSyntaxError:
        raise
    except Exception:
        raise djangot.TemplateSyntaxError, "partial tag expects a dictionary, like {% partial designer/wild.txt {'hello': neato, 'goodbye': dolly} %}"
    return PartialNode(template_path, dictionary_info)

class PartialNode(djangot.Node):
    def __init__(self, template_path, dictionary_info):
        self.template_path = template_path
        self.dictionary_info = dictionary_info

    def render(self, context):
        new_context = {}

        # Run through the dictionary and evaluate it
        for key, value_name in self.dictionary_info.iteritems():
            new_context_value = _resolve_variable_or_expression(value_name, context)
            new_context[key] = new_context_value

        # Render the template
        final_template = djangot_get_template(self.template_path)
        return final_template.render(djangot_Context(new_context))

def parse_dictionary_string(s):
    s = s.strip()

    # NOTE this is first-pass code only -- complete hack; use regexps, etc.

    # test dictionary syntax
    if s[0] != '{' or s[-1] != '}':
        raise djangot.TemplateSyntaxError, "Malformed dictionary in partial tag. Must start and end with {}"        
    s = s[1:-1]

    # split key/value pairs
    kvp_strings = [kvp.strip() for kvp in s.split(',')]
    kvps = {}

    for kvp_string in kvp_strings:
        split = kvp_string.split(':')
        key = split[0].strip()
        value_name = split[1].strip()        
        if key[0] == '\'':
            if key[-1] != '\'':
                raise djangot.TemplateSyntaxError, "Malformed dictionary in partial tag. A key is improperly quoted."
            else:
                key = key[1:-1]
        if key[0] == '"':
            if key[-1] != '"':
                raise djangot.TemplateSyntaxError, "Malformed dictionary in partial tag. A key is improperly quoted."
            else:
                key = key[1:-1]
        kvps[key] = value_name

    return kvps