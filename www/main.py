#!/usr/bin/env python
import datetime

import wsgiref.handlers
from django.utils import simplejson
from google.appengine.ext import db
from google.appengine.ext import webapp

import sharedutil

class LocationUpdate(db.Model):
    twitter_user_name = db.StringProperty(multiline=False)
    twitter_profile_image_url = db.LinkProperty()
    hashtag = db.StringProperty()
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    message = db.StringProperty()
    update_datetime = db.DateTimeProperty(auto_now_add=True)


class HashTagHandler(webapp.RequestHandler):
    def get(self, hashtag):
        data = []
        query = LocationUpdate.all()
        query.filter('hashtag =', hashtag)
        for item in query:
            update = sharedutil.LocationUpdateJSON()
            data.append(update)

        self.response.headers['Content-Type'] = 'application/json'

        callback = self.request.get("callback")
        if callback:
            data = '%s(%s);' % (callback, simplejson.dumps(data))
            self.response.out.write(data)
        else:
            self.response.out.write(simplejson.dumps(data))

class UpdateHandler(webapp.RequestHandler):
    def post(self):
        data = simplejson.loads(self.request.body)
        update = LocationUpdate.get_or_insert(
                        key_name = data['twitter_user_name'])
        update.twitter_user_name = data['twitter_user_name']
        update.twitter_profile_image_url = data['twitter_profile_image_url']
        update.hashtag = data['hashtag']
        update.latitude = data['latitude']
        update.longitude = data['longitude']
        update.message = data['message']
        update.update_datetime = datetime.datetime.utcnow()
        update.put()
        self.response.out.write(simplejson.dumps(data))

class MainHandler(webapp.RequestHandler):

  def get(self):
    self.response.out.write('Hello world!')


def main():
  application = webapp.WSGIApplication([('/', MainHandler),
                                       ('/api/1/hashtag/(.*)', HashTagHandler),
                                       ('/api/1/update/', UpdateHandler),
                                       ]
                                       )
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
