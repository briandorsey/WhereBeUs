import datetime
import simplejson

import py
import sharedutil

def create_LocationUpdateJSON():
    update = sharedutil.LocationUpdateJSON()
    update.display_name = 'Full Name'
    update.profile_image_url = 'http://someurl'
    update.latitude = 123.456
    update.longitude = 123.456
    update.message = "this is the message"
    update.message_time = None
    return update

def test_LocationUpdateJSON():
    update = create_LocationUpdateJSON()

    py.test.raises(AttributeError, getattr, update, 'not_a_property')
    print update

    # make sure it dumps
    update_json = simplejson.dumps(update, indent=4)
    print update_json

