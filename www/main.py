#!/usr/bin/env python
import os
import sys
import datetime
import logging
import traceback

import wsgiref.handlers
from django.utils import simplejson
from google.appengine.ext import db
from google.appengine.ext import webapp


#------------------------------------------------------------------------------
# Helper Methods
#------------------------------------------------------------------------------

RUNNING_APPENGINE_LOCAL_SERVER = True # For now, so we can see behavior in production too... -- later = os.environ.get('SERVER_SOFTWARE', 'Dev').startswith('Dev')

def BREAKPOINT():
  import pdb
  p = pdb.Pdb(None, sys.__stdin__, sys.__stdout__)
  p.set_trace()
  
def _typename(t):
    if t:
        return str(t).split("'")[1]
    else:
        return "{type: None}"

def exception_string():
    exc = sys.exc_info()
    exc_type = _typename(exc[0])
    exc_message = str(exc[1])
    exc_contents = "".join(traceback.format_exception(*sys.exc_info()))
    return "[%s]\n %s" % (exc_type, exc_contents)
  
def get_rid_of_microseconds(dt):
    return datetime.datetime(year=dt.year, month=dt.month, day=dt.day, hour=dt.hour, minute=dt.minute, second=dt.second)

def iso_utc_string(dt):
    no_micros = get_rid_of_microseconds(dt)

    # after digging around in datetime for too long, I gave up and
    # hacked the UTC mark in.
    return no_micros.isoformat() + "Z"


#------------------------------------------------------------------------------
# App Engine Models
#------------------------------------------------------------------------------

class User(db.Model):
    display_name = db.StringProperty()
    profile_image_url = db.LinkProperty()    
    message = db.StringProperty()
    message_time = db.DateTimeProperty()

class UserService(db.Model):
    KNOWN_SERVICE_TYPES = ['twitter', 'facebook']    
    
    user = db.ReferenceProperty(User, collection_name = "services")
    display_name = db.StringProperty()
    profile_image_url = db.LinkProperty()    
    service_type = db.StringProperty()  # "twitter"
    id_on_service = db.IntegerProperty() # 12345
    friend_ids = db.ListProperty(int)   # [12345, 6789]
    
    @staticmethod
    def key_for_service_and_id(service_type, id_on_service):
        return 'us-%s-%s' % (service_type, str(id_on_service))
    
    @staticmethod
    def get_or_insert_for_service_and_id(service_type, id_on_service):
        if service_type not in UserService.KNOWN_SERVICE_TYPES:
            raise Exception("Invalid service_type")
        key_name = UserService.key_for_service_and_id(service_type, id_on_service)
        user_service = UserService.get_or_insert(key_name = key_name)
        user_service.service_type = service_type
        user_service.id_on_service = id_on_service
        if user_service.friend_ids is None:
            user_service.friend_ids = []
        return user_service
        
    def iter_friend_services(self):
        # TODO davepeck :: clearly we need a very different data model
        for friend_id in self.friend_ids:
            try:
                key = db.Key(UserService.key_for_service_and_id(service_type = self.service_type, id_on_service = friend_id))
            except db.BadKeyError:
                pass
            else:
                yield UserService.get(key)
    
    def iter_friend_users(self):
        for friend_service in self.iter_friend_services():
            yield friend_service.user
        
    def iter_friend_updates(self):
        for friend_user in self.iter_friend_users():
            if friend_user.location_updates:
                location_update = friend_user.location_updates[0]
                update = {
                    "display_name": friend_user.display_name,
                    "profile_image_url": friend_user.profile_image_url,
                    "latitude": location_update.location.lat,
                    "longitude": location_update.location.lon,
                    "update_time": iso_utc_string(location_update.update_time),
                    "message": friend_user.message if friend_user.message else ""
                }
                yield update
                
    @staticmethod
    def iter_updates_for_user_services(user_services):
        seen = {}
        for user_service in user_services:
            for update in user_service.iter_friend_updates():
                key = (update["display_name"], update["profile_image_url"])
                if key not in seen:
                    seen[key] = True
                    yield update
                    
    @staticmethod
    def updates_for_user_services(user_services):
        return [update for update in UserService.iter_updates_for_user_services(user_services)]
        
class LocationUpdate(db.Model):
    user = db.ReferenceProperty(User, collection_name = "location_updates")
    location = db.GeoPtProperty()
    update_time = db.DateTimeProperty()
    horizontal_accuracy = db.FloatProperty()


#------------------------------------------------------------------------------
# UpdateHandler
#------------------------------------------------------------------------------

class UpdateHandler(webapp.RequestHandler):
    def post(self):
        try:
            user = None

            # Read data and basic sandity check
            data = simplejson.loads(self.request.body.decode('utf8'))
            if RUNNING_APPENGINE_LOCAL_SERVER:
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
            self.response.headers['Content-Type'] = 'application/json'
            if RUNNING_APPENGINE_LOCAL_SERVER:            
                logging.info("\n\n*** RESPONSE: \n%s\n" % simplejson.dumps(result))
            self.response.out.write(simplejson.dumps(result))


#------------------------------------------------------------------------------
# Other Misc. Handlers
#------------------------------------------------------------------------------

class MainHandler(webapp.RequestHandler):
    def get(self):
        self.response.out.write('Hello world!')

class ViewHandler(webapp.RequestHandler):
    def get(self, hashtag):
        self.response.headers['Content-Type'] = 'text/html'
        # XXX TODO something real
        self.response.out.write('<html><head><title>[View Tag %s]</title></head><body><a style="font-size: 18pt; font-family:Helvetica Neue" href="tweetthespotone://%s/">Open TweetTheSpot with "%s"</a><br/></body></html>\n' % (hashtag, hashtag, hashtag))


#------------------------------------------------------------------------------
# Bootstrapping
#------------------------------------------------------------------------------

def main():
  application = webapp.WSGIApplication([('/', MainHandler),
                                       ('/api/1/update/', UpdateHandler),
                                       ('/v/(.*)/', ViewHandler),
                                       ]
                                       )
  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
