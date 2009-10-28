import datetime
import simplejson

import py
import httplib2
import sharedutil

base_url = "http://localhost:8082"

def create_LocationUpdateJSON():
    update = sharedutil.LocationUpdateJSON()
    update.twitter_user_name = 'name'
    update.hashtag = 'hashtag'
    update.twitter_profile_image_url = 'http://someurl'
    update.latitude = 123.456
    update.longitude = 123.456
    update.message = "this is the message"
    update.update_datetime = datetime.datetime.utcnow().isoformat()
    return update

def test_LocationUpdateJSON():
    update = create_LocationUpdateJSON()

    py.test.raises(AttributeError, getattr, update, 'not_a_property')
    print update

    # make sure it dumps
    update_json = simplejson.dumps(update, indent=4)
    print update_json

def test_get_root():
    """make sure we can even just query the root"""
    url = base_url + '/'
    h = httplib2.Http()
    resp, content = h.request(url, 'GET')
    print url
    assert resp['status'] == '200'
    print resp
    print content

def test_get_updates():
    url = base_url + '/api/1/hashtag/testtag'
    h = httplib2.Http()
    resp, content = h.request(url, 'GET')
    print url
    assert resp['status'] == '200'
    print resp
    print content
    json = simplejson.loads(content)
    print json

def test_post_update():
    update = create_LocationUpdateJSON()

