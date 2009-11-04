import datetime
import simplejson

import py
import httplib2
import sharedutil

base_url = "http://localhost:8082"
#base_url = "http://ourtweetspot.appspot.com"

def create_LocationUpdateJSON():
    update = sharedutil.LocationUpdateJSON()
    update.twitter_username = 'name'
    update.twitter_full_name = 'Full Name'
    update.hashtag = 'hashtag'
    update.twitter_profile_image_url = 'http://someurl'
    update.latitude = 123.456
    update.longitude = 123.456
    update.message = "this is the message"
    return update

def check_json_response(response):
    assert 'success' in response
    assert 'message' in response

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
    check_json_response(json_response)
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
    json_response = simplejson.loads(content)
    check_json_response(json_response)
    assert json_response['success'] == True

    url = base_url + '/api/1/hashtag/posttag/'
    resp, content = h.request(url, 'GET')
    print url
    assert resp['status'] == '200'
    print resp
    print content
    json_response = simplejson.loads(content)
    print json_response
    check_json_response(json_response)
    assert 'call_again_seconds' in json_response
    assert 'updates' in json_response
    assert len(json_response['updates']) == 1
    update_data = json_response['updates'][0]
    for key in sharedutil.LocationUpdateJSON().__allowed_attributes__:
        print key
        assert key in update_data
    assert update_data['update_datetime'].endswith('Z')


# TODO: add a test for malformed update json - make sure it returns 400 or 500
# http codes for errors
