import datetime
import simplejson

import py
import httplib2
import sharedutil

base_url = "http://localhost:8082"

def create_LocationUpdateJSON():
    update = sharedutil.LocationUpdateJSON()
    update.twitter_username = 'name'
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
    url = base_url + '/api/1/hashtag/testtag/'
    h = httplib2.Http()
    resp, content = h.request(url, 'GET')
    print url
    assert resp['status'] == '200'
    print resp
    print content
    json_response = simplejson.loads(content)
    print json_response
    assert 'success' in json_response
    assert 'message' in json_response
    assert 'call_again_seconds' in json_response
    assert 'updates' in json_response
    assert len(json_response['updates']) == 0

def test_post_update():
    url = base_url + '/api/1/update/'
    h = httplib2.Http()
    update = create_LocationUpdateJSON()
    update.hashtag = 'posttag'
    json_data = simplejson.dumps(update)
    resp, content = h.request(url,
                            'POST', body=json_data,
                            headers={'content-type':'application/json'} )
    print json_data
    print url
    print resp
    print content
    assert resp['status'] == '200'
    returned_data = simplejson.loads(content)
    # TODO: do we want to assert that the return is the update? or, should we
    # return the hashtag query instead?
    # assert json_data == returned_data

