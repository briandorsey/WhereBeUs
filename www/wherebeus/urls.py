# NOTE: Must import *, since Django looks for things here, e.g. handler500.
from django.conf.urls.defaults import *

urlpatterns = patterns('')

urlpatterns += patterns(
    'wherebeus.views',
    url(r'^$', 'static', {'template': 'index.html'}, name='index'),
    url(r'^about/iphone/$', 'static', {'template': 'about-iphone.html'}, name='about-iphone'),
    url(r'^api/1/update/$', 'api_1_update', name='api_update'),
)

