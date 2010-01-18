import os
import sys
import datetime
import django

from django.conf import settings
from django.template import RequestContext
from django.core.urlresolvers import reverse
from django.utils import simplejson as json
from django.http import HttpResponseRedirect, Http404, HttpResponse, HttpResponseBadRequest, HttpResponseNotAllowed


#------------------------------------------------------------------------------
# View Utilities
#------------------------------------------------------------------------------

def render_to_response(request, template_name, dictionary={}, **kwargs):
    """
    Similar to django.shortcuts.render_to_response, but uses a RequestContext
    with some site-wide context.
    """
    response = django.shortcuts.render_to_response(
        template_name,
        dictionary,
        context_instance=RequestContext(request),
        **kwargs
    )

    return response

def redirect_to(view, *args, **kwargs):
    """
    Similar to urlresolvers.reverse, but returns an HttpResponseRedirect for the
    URL.
    """
    url = reverse(view, args = args, kwargs = kwargs)
    return HttpResponseRedirect(url)
    
def not_implemented(request):
    return render_to_response(request, "not-implemented.html")

def render_image_response(request, image_bytes, mimetype = 'image/png'):
    return HttpResponse(image_bytes, mimetype)

def redirect_to_url(url):
    return HttpResponseRedirect(url)

def bad_request(message = ''):
    return HttpResponseBadRequest(message)
    
def method_not_allowed(message = ''):
    return HttpResponseNotAllowed(message)
    
def render_json(jsonable, status = 200):
    # For sanity's sake, when debugging use text/x-json...
    # ...but in production, the one true JSON mimetype is application/json. 
    # Ask IANA if you don't believe me.
    return HttpResponse(json.dumps(jsonable), 
                        mimetype = 'text/x-json' if settings.DEBUG else 'application/json', 
                        status = status)

def render_text(text):
    return HttpResponse(text, mimetype = 'text/plain')

def render_csv(csv):
    return HttpResponse(csv, mimetype = 'text/csv')
    
def raise_404():
    raise Http404


#------------------------------------------------------------------------------
# Time & Date Utilities
#------------------------------------------------------------------------------

def get_rid_of_microseconds(dt):
    return datetime.datetime(year=dt.year, month=dt.month, day=dt.day, hour=dt.hour, minute=dt.minute, second=dt.second)

def iso_utc_string(dt):
    no_micros = get_rid_of_microseconds(dt)

    # after digging around in datetime for too long, I gave up and
    # hacked the UTC mark in.
    return no_micros.isoformat() + "Z"


#------------------------------------------------------------------------------
# Misc.
#------------------------------------------------------------------------------

def chunk_sequence(sequence, chunk_size):
    chunk = []
    for item in sequence:
        chunk.append(item)
        if len(chunk) >= chunk_size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk
