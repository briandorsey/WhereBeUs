import copy
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

    "want_updates": True,
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


def test_friends_can_see_each_other():
    h = httplib2.Http()
    user_a = copy.deepcopy(TEMPLATE_DATA)
    user_a['services'][0]['id_on_service'] = 123
    user_a['services'][0]['display_name'] = 'User A'
    user_a['services'][0]['friends'].append(321)
    # test with just one service defined
    del(user_a['services'][1])
    user_b = copy.deepcopy(TEMPLATE_DATA)
    user_b['services'][0]['id_on_service'] = 321
    user_b['services'][0]['display_name'] = 'User B'
    user_b['services'][0]['friends'].append(123)
    del(user_b['services'][1])

    json_a = simplejson.dumps(user_a)
    json_b = simplejson.dumps(user_b)

    resp_a, content_a = h.request(UPDATE_URL,
                            'POST', body=json_a,
                            headers={'content-type':'application/json'} )
    resp_b, content_b = h.request(UPDATE_URL,
                            'POST', body=json_b,
                            headers={'content-type':'application/json'} )

    content_a = simplejson.loads(content_a)
    check_json_response(content_a)
    assert content_a['success'] == True
    assert content_a['updates'][0]['display_name'] == 'User B'

    content_b = simplejson.loads(content_b)
    check_json_response(content_b)
    assert content_b['success'] == True
    assert content_b['updates'][0]['display_name'] == 'User A'

# TODO: add a test for malformed update json - make sure it returns 400 or 500
# http codes for errors
