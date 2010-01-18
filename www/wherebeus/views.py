import os
import sys
import logging
import datetime

from django.conf import settings
from django.utils import simplejson as json

from google.appengine.ext import db

from bootstrap import exception_string
from .models import UserService
from .utils import render_json, render_to_response, bad_request
from .decorators import requires_GET, requires_POST

@requires_GET
def static(request, template):
    return render_to_response(request, template)
    
@requires_POST
def api_1_update(request):
    result = {'success': False, 'message': 'Did not compute a result.'}
    try:
        update_time = datetime.datetime.utcnow()

        # Read data and basic sandity check
        data = json.loads(request.raw_post_data.decode('utf8'))
        if settings.RUNNING_APP_ENGINE_LOCAL_SERVER:
            logging.info("\n\n*** REQUEST: \n%s\n" % data)
        
        services = data.get('services', None)
        if not services:
            result['message'] = 'You must include service information in your post.'
            return render_json(result, status=400)
        
        # Handle location, if included
        latitude = float(data.get('latitude', 0.0))
        longitude = float(data.get('longitude', 0.0))

        # Handle message, if any:
        message = data.get('message', None)
        if message is not None:
            message = message.strip()
        
        # Handle information for each service
        user_services = []
        for service in services:
            user_service = UserService.get_or_insert_for_service_and_id(service['service_type'], service['id_on_service'])
            user_service.screen_name = service.get('screen_name', user_service.screen_name)
            user_service.display_name = service.get('display_name', user_service.display_name)
            user_service.profile_image_url = service.get('profile_image_url', user_service.profile_image_url)
            user_service.large_profile_image_url = service.get('large_profile_image_url', user_service.large_profile_image_url)
            user_service.service_url = service.get('service_url', user_service.service_url)
            user_serivce.update_time = update_time
            
            if latitude or longitude:
                user_service.location = db.GeoPt(latitude, longitude)
                
            if message:
                user_service.message = message
                user_service.message_time = update_time
                
            followers = service.get('followers', None)
            if followers is not None:
                user_service.set_followers(followers)
                
            user_services.append(user_service)
            
        # Attempt to save everything in the datastore... (failure will get caught)
        db.put(user_services)
        
        # Now cons up some updates, if they're desired...
        want_updates = data.get('want_updates', False)
        if want_updates:
            updates = UserService.updates_for_user_services(user_services)
        else:
            updates = []                
    except Exception, message:
        result['message'] = 'Encountered an unexpected exception (%s %s)' % (message, exception_string())            
        if not settings.RUNNING_APP_ENGINE_LOCAL_SERVER:
            logging.info("\n\n*** REQUEST: \n%s\n" % data)
            logging.info("\n\n*** RESPONSE: \n%s\n" % json.dumps(result))
        logging.error("\n\n*** ERROR: \n%s\n" % result['message'])
        return render_json(result, status=500)
    else:
        result['success'] = True
        result['message'] = 'OK'
        result['updates'] = updates

    if settings.RUNNING_APP_ENGINE_LOCAL_SERVER:            
        logging.info("\n\n*** RESPONSE: \n%s\n" % json.dumps(result))
    return render_json(result)

        
