import datetime
import simplejson

import py
import httplib2

import sharedutil_test

base_url = "http://localhost:8082"
#base_url = "http://ourtweetspot.appspot.com"

#TODO: startup test dev_appserver.py in it's own dir for the tests

def check_json_response(response):
    assert 'success' in response
    assert 'message' in response

def test_get_root():
    """make sure we can even talk to the web server"""
    url = base_url + '/'
    h = httplib2.Http()
    resp, content = h.request(url, 'GET')
    print url
    print resp
    print content
    assert resp['status'] == '200'

def test_get_updates():
    py.test.skip("disabled for rewrite of req/response protocol")
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
    data = {
        "services":
        [
            {
                "service_type": "twitter",
                "display_name": "Twitter Name",
                "profile_image_url": "http://example.com/twitter/",
                "id_on_service": 12345,
                "friends": [67890, 999, 312],
            },


            {
                "service_type": "facebook",
                "display_name": "Facebook Name",
                "profile_image_url": "http://example.com/facebook/",
                "id_on_service": 23456,
                # "friends" key is optional
            },
        ],

        "want_updates": True,
        "latitude": 77.33,
        "longitude": 99.22,
        "message": "My current message.",
        }
    json_data = simplejson.dumps(data)
    print json_data
    resp, content = h.request(url,
                            'POST', body=json_data,
                            headers={'content-type':'application/json'} )
    print url
    print resp
    print content
    assert resp['status'] == '200'
    json_response = simplejson.loads(content)
    check_json_response(json_response)
    assert json_response['success'] == True

    """
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
    assert update_data['update_time'].endswith('Z')
    """

# TODO: add a test for malformed update json - make sure it returns 400 or 500
# http codes for errors
