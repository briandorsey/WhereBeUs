#!/usr/bin/env python


import wsgiref.handlers
from django.utils import simplejson
from google.appengine.ext import db
from google.appengine.ext import webapp

import sharedutil

class LocationUpdate(db.model):
    twitter_user_name = dbStringProperty(multiline=False)
    twitter_profile_image_url = db.LinkProperty()
    hashtag = db.StringProperty()
    latitude = db.FloatProperty()
    longitude = db.FloatProperty()
    message = db.StringProperty()
    update_datetime = db.DateTimeProperty(auto_now_add=True)


class MainHandler(webapp.RequestHandler):

  def get(self):
    self.response.out.write('Hello world!')


def main():
  application = webapp.WSGIApplication([('/', MainHandler)],
                                       debug=True)
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
