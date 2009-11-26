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

class TwitterUser(db.Model):
    user_id = db.IntProperty()
    username = db.StringProperty()
    full_name = db.StringProperty()
    profile_image_url = db.LinkProperty()
    friend_ids = db.ListProperty(int)
    
class FacebookUser(db.Model):
    pass # XXX TODO    
        
class LocationUpdate(db.Model):
    twitter_user = db.ReferenceProperty(TwitterUser)
    # Soon, also facebook_user
    
    when = db.DateTimeProperty(auto_now_add=True)
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()

    

    
class HashTagHandler(webapp.RequestHandler):
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

class UpdateHandler(webapp.RequestHandler):
    def post(self):
        try:
            data = simplejson.loads(self.request.body.decode('utf8'))
            update = LocationUpdate.get_or_insert(key_name = data['twitter_username'])
            update.twitter_username = data['twitter_username']
            update.twitter_full_name = data['twitter_full_name']
            update.twitter_profile_image_url = data['twitter_profile_image_url']
            update.hashtag = data['hashtag']
            update.latitude = data['latitude']
            update.longitude = data['longitude']
            update.message = data['message']
            update.update_datetime = datetime.datetime.utcnow()
        except:
            response = {'success': False, 'message': 'Malformed POST request.'}
        else:
            try:
                update.put()
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
                                       ('/api/1/hashtag/(.*)/', HashTagHandler),
                                       ('/api/1/update/', UpdateHandler),
                                       ('/v/(.*)/', ViewHandler),
                                       ]
                                       )
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
