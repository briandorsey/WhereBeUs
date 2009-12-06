#!/usr/bin/env python
import datetime

import sys
import wsgiref.handlers
from django.utils import simplejson
from google.appengine.ext import db
from google.appengine.ext import webapp

import sharedutil

def get_rid_of_microseconds(dt):
    return datetime.datetime(year=dt.year, month=dt.month, day=dt.day, hour=dt.hour, minute=dt.minute, second=dt.second)

def iso_utc_string(dt):
    no_micros = get_rid_of_microseconds(dt)

    # after digging around in datetime for too long, I gave up and
    # hacked the UTC mark in.
    return no_micros.isoformat() + "Z"

def BREAKPOINT():
  import pdb
  p = pdb.Pdb(None, sys.__stdin__, sys.__stdout__)
  p.set_trace()

# DataStore classes
class User(db.Model):
    display_name = db.StringProperty()
    profile_image_url = db.LinkProperty()

class UserService(db.Model):
    user = db.ReferenceProperty(User, collection_name = "services")
    display_name = db.StringProperty()
    profile_image_url = db.LinkProperty()
    service_type = db.StringProperty()  # "twitter"
    id_on_service = db.IntegerProperty() # 12345
    friend_ids = db.ListProperty(int)   # [12345, 6789]

class LocationUpdate(db.Model):
    user = db.ReferenceProperty(User, collection_name = "locations")
    location = db.GeoPtProperty()
    update_time = db.DateTimeProperty(auto_now_add=True)
    horizontal_accuracy = db.FloatProperty()

# Handlers
class UpdateHandler(webapp.RequestHandler):
    @staticmethod
    def location_update_dictionary(update):
        location_update = sharedutil.LocationUpdateJSON()
        location_update.twitter_username = update.twitter_username
        location_update.twitter_full_name = update.twitter_full_name
        location_update.twitter_profile_image_url = str(update.twitter_profile_image_url)
        location_update.hashtag = update.hashtag
        location_update.message = update.message
        location_update.latitude = update.latitude
        location_update.longitude = update.longitude
        location_update.update_datetime = iso_utc_string(update.update_datetime)
        return location_update

    def get(self, hashtag):
        try:
            update_list = []
            updates = LocationUpdate.all().filter('hashtag =', hashtag).fetch(100)
            for update in updates:
                update_list.append(HashTagHandler.location_update_dictionary(update))
        except:
            response = {'success': False, 'message': 'Datastore failure', 'call_again_seconds': 15, 'updates': []}
        else:
            response = {'success': True, 'message': 'OK', 'call_again_seconds': 15, 'updates': update_list}

        self.response.headers['Content-Type'] = 'application/json'
        callback = self.request.get("callback")
        if callback:
            data = '%s(%s);' % (callback, simplejson.dumps(response))
            self.response.out.write(data)
        else:
            self.response.out.write(simplejson.dumps(response))
            #sys.__stdout__.write(simplejson.dumps(response))
            #sys.__stdout__.flush()

    def post(self):
        response = {'success': False, 'message': 'Unforseen error condition.'}
        try:
            data = simplejson.loads(self.request.body.decode('utf8'))
            user = None
            update_queue = []
            for service in data['services']:
                key_name = '%s%s' % (service['service_type'], service['id_on_service'])
                user_service = UserService.get_or_insert(key_name = key_name)
                user_service.id_on_service = service['id_on_service']
                user_service.service_type = service['service_type']
                user_service.display_name = service['display_name']
                user_service.profile_image_url = service['profile_image_url']
                update_queue.append(user_service)

                if not user and not user_service.user:
                    user = User()
                    #TODO: use Twitter data in case of conflict
                    user.display_name = user_service.display_name
                    user.profile_image_url = user_service.profile_image_url
                    #TODO: error checking
                    user.put()
                    user_service.user = user
                elif user and not user_service.user:
                    user_service.user = user

#            update = LocationUpdate.get_or_insert(key_name = data['twitter_username'])
#            update.twitter_username = data['twitter_username']
#            update.twitter_full_name = data['twitter_full_name']
#            update.twitter_profile_image_url = data['twitter_profile_image_url']
#            update.hashtag = data['hashtag']
#            update.latitude = data['latitude']
#            update.longitude = data['longitude']
#            update.message = data['message']
#            update.update_datetime = datetime.datetime.utcnow()
        except KeyError:
            response = {'success': False, 'message': 'Malformed POST request.'}
        else:
            try:
                #TODO: is there a better way to commit all updated instances?
                for item in update_queue:
                    item.put()
            except:
                response = {'success': False, 'message': 'Datastore timeout or other error.'}
            else:
                response = {'success': True, 'message': 'OK'}
        finally:
            self.response.headers['Content-Type'] = 'application/json'
            self.response.out.write(simplejson.dumps(response))

class MainHandler(webapp.RequestHandler):
    def get(self):
        self.response.out.write('Hello world!')

class ViewHandler(webapp.RequestHandler):
    def get(self, hashtag):
        self.response.headers['Content-Type'] = 'text/html'
        # XXX TODO something real
        self.response.out.write('<html><head><title>[View Tag %s]</title></head><body><a style="font-size: 18pt; font-family:Helvetica Neue" href="tweetthespotone://%s/">Open TweetTheSpot with "%s"</a><br/></body></html>\n' % (hashtag, hashtag, hashtag))

def main():
  application = webapp.WSGIApplication([('/', MainHandler),
                                       ('/api/1/update/', UpdateHandler),
                                       ('/v/(.*)/', ViewHandler),
                                       ]
                                       )
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
