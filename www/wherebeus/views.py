import os
import sys
import logging
import datetime

from django.conf import settings
from django.utils import simplejson as json

from google.appengine.ext import db

from bootstrap import exception_string
from .models import User, UserService, LocationUpdate
from .utils import render_json, render_to_response
from .decorators import requires_GET, requires_POST

@requires_GET
def static(request, template):
    return render_to_response(request, template)

@requires_POST
def api_1_update(request):
    try:
        user = None

        # Read data and basic sandity check
        data = json.loads(request.raw_post_data.decode('utf8'))
        if settings.RUNNING_APP_ENGINE_LOCAL_SERVER:
            logging.info("\n\n*** REQUEST: \n%s\n" % data)
        
        services = data.get('services', None)
        if not services:
            raise Exception('You must include service information in your post.')                         
        
        # Handle information for each service
        info_from = None 
        user_services = []
        for service in services:
            user_service = UserService.get_or_insert_for_service_and_id(service['service_type'], service['id_on_service'])
            user_service.display_name = service.get('display_name', user_service.display_name)
            user_service.profile_image_url = service.get('profile_image_url', user_service.profile_image_url)
            user_service.friend_ids = service.get('friends', user_service.friend_ids)
            user_services.append(user_service)

            if user is None:
                user = user_service.user                
                if user is None: 
                    user = User()
                    user.put() # TODO error handling!                 
            user_service.user = user
            
            if info_from != "twitter":
                user.display_name = user_service.display_name
                user.profile_image_url = user_service.profile_image_url
                info_from = user_service.service_type
            user_services.append(user_service)
            
        # Handle location update, if included
        location_update = None
        latitude = float(data.get('latitude', 0.0))
        longitude = float(data.get('longitude', 0.0))
        horizontal_accuracy = float(data.get('horizontal_accuracy', 0.0))
        if latitude and longitude:
            # For now, only keep the most recent location
            all_location_updates = [location_update for location_update in user.location_updates]
            if all_location_updates:
                location_update = all_location_updates[0]
            else:
                location_update = LocationUpdate(user = user)
            location_update.location = db.GeoPt(latitude, longitude)
            location_update.horizontal_accuracy = horizontal_accuracy
            location_update.update_time = datetime.datetime.utcnow()
        
        # Handle message, if any:
        message = data.get('message', None)
        if message:
            user.message = message
            user.message_time = datetime.datetime.utcnow()
            
        # Attempt to save everything in the datastore... (failure will get caught)
        user.put()
        if location_update:
            location_update.put()
        db.put(user_services)            
            
        # Now cons up some updates, if they're desired...
        want_updates = data.get('want_updates', False)
        if want_updates:
            updates = UserService.updates_for_user_services(user_services)
        else:
            updates = []                
    except Exception, message:
        result = {'success': False, 'message': 'Encountered an unexpected exception (%s %s)' % (message, exception_string())}            
    else:
        result = {'success': True, 'message': 'OK', 'updates': updates}
    finally:
        if settings.RUNNING_APP_ENGINE_LOCAL_SERVER:            
            logging.info("\n\n*** RESPONSE: \n%s\n" % json.dumps(result))
        return render_json(result)

        
