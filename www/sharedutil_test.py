import datetime
import simplejson

import py
import sharedutil

base_url = "http://localhost:8082/"

def test_LocationUpdateJSON():
    update = sharedutil.LocationUpdateJSON()
    update.twitter_user_name = 'name'
    update.hashtag = 'hashtag'
    update.twitter_profile_image_url = 'http://someurl'
    update.latitude = 123.456
    update.longitude = 123.456
    update.message = "this is the message"
    update.update_datetime = datetime.datetime.utcnow().isoformat()

    py.test.raises(AttributeError, getattr, update, 'not_a_property')
    print update

    # make sure it dumps
    update_json = simplejson.dumps(update, indent=4)
    print update_json

def test_post_location():
    pass


