#!/usr/bin/env python
import datetime

import sys
import wsgiref.handlers
from django.utils import simplejson
from google.appengine.ext import db
from google.appengine.ext import webapp

def BREAKPOINT():
  import pdb
  p = pdb.Pdb(None, sys.__stdin__, sys.__stdout__)
  p.set_trace()

class LocationUpdate(db.Model):
    twitter_user_name = db.StringProperty()
    twitter_full_name = db.StringProperty()
    twitter_profile_image_url = db.LinkProperty()
    hashtag = db.StringProperty()
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    update_datetime = db.DateTimeProperty()
    
class HashTagHandler(webapp.RequestHandler):
    @staticmethod
    def location_update_dictionary(update):
        return {
            'twitter_user_name': update.twitter_user_name, 
            'twitter_full_name': update.twitter_full_name,
            'twitter_profile_image_url': str(update.twitter_profile_image_url),
            'latitude': update.latitude,
            'longitude': update.longitude,
            'update_datetime': update.update_datetime.isoformat()
        }

    def get(self, hashtag):
        data = []
        updates = LocationUpdate.all().filter('hashtag =', hashtag).fetch(100)
        for update in updates:
            data.append(HashTagHandler.location_update_dictionary(update))
        self.response.headers['Content-Type'] = 'application/json'
        callback = self.request.get("callback")
        if callback:
            data = '%s(%s);' % (callback, simplejson.dumps(data))
            self.response.out.write(data)
        else:
            self.response.out.write(simplejson.dumps(data))

class UpdateHandler(webapp.RequestHandler):
    def post(self):
        try:
            data = simplejson.loads(self.request.body)        
            update = LocationUpdate.get_or_insert(key_name = data['twitter_user_name'])
            update.twitter_user_name = data['twitter_user_name']
            update.twitter_full_name = data['twitter_full_name']
            update.twitter_profile_image_url = data['twitter_profile_image_url']
            update.hashtag = data['hashtag']
            update.latitude = data['latitude']
            update.longitude = data['longitude']
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


def main():
  application = webapp.WSGIApplication([('/', MainHandler),
                                       ('/api/1/hashtag/(.*)/', HashTagHandler),
                                       ('/api/1/update/', UpdateHandler),
                                       ]
                                       )
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
