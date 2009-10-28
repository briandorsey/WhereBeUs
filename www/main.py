#!/usr/bin/env python


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
        data.append(hashtag)
        """
        query = Update.all()
        query.filter('enabled', True)
        for item in query:
            data.append(item.content)
        random.shuffle(data)
        data = data[:100]
        """
        self.response.headers['Content-Type'] = 'application/json'

        callback = self.request.get("callback")
        if callback:
            data = '%s(%s);' % (callback, simplejson.dumps(data))
            self.response.out.write(data)
        else:
            self.response.out.write(simplejson.dumps(data))

class MainHandler(webapp.RequestHandler):

  def get(self):
    self.response.out.write('Hello world!')


def main():
  application = webapp.WSGIApplication([('/', MainHandler),
                                       ('/api/1/hashtag/(.*)', HashTagHandler),
                                       ]
                                       )
  wsgiref.handlers.CGIHandler().run(application)


if __name__ == '__main__':
  main()
