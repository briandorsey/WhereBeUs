import datetime
import simplejson

import py
import httplib2

import sharedutil_test

BASE_URL = "http://localhost:8082/"
#BASE_URL = "http://ourtweetspot.appspot.com"
UPDATE_URL = BASE_URL + 'api/1/update/'

TEMPLATE_DATA = {
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

    "want_updates": False,
    "latitude": 77.33,
    "longitude": 99.22,
    "message": "My current message.",
    }
#TODO: startup test dev_appserver.py in it's own dir for the tests

def check_json_response(response):
    assert 'success' in response
    assert 'message' in response

def test_get_root():
    """make sure we can even talk to the web server"""
    h = httplib2.Http()
    resp, content = h.request(BASE_URL, 'GET')
    print BASE_URL
    print resp
    print content
    assert resp['status'] == '200'


def test_post_update():
    h = httplib2.Http()
    json_data = simplejson.dumps(TEMPLATE_DATA)
    print json_data
    resp, content = h.request(UPDATE_URL,
                            'POST', body=json_data,
                            headers={'content-type':'application/json'} )
    print UPDATE_URL
    print resp
    print content
    assert resp['status'] == '200'
    json_response = simplejson.loads(content)
    check_json_response(json_response)
    assert json_response['success'] == True

    """
    url = BASE_URL + 'api/1/hashtag/posttag/'
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
