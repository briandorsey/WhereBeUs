# NOTE: Must import *, since Django looks for things here, e.g. handler500.
from django.conf.urls.defaults import *

urlpatterns = patterns('')

urlpatterns += patterns(
    'wherebeus.views',
    url(r'^$', 'static', {'template': 'index.html'}, name='index'),
    url(r'^api/1/update/$', 'api_1_update', name='api_update'),
    url(r'^api/1/user_service/(?P<service_type>\w+)/(?P<id_on_service>\d+)/$', 'api_1_user_service_details', name='api_user_service'),
)

