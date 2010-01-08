//
//  TwitterService.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "JsonConnection.h"
#import "FBConnect/FBRequest.h"

#define TWITTER_USER_ID @"id"
#define TWITTER_DISPLAY_NAME @"name"
#define TWITTER_ACCOUNT_NAME @"screen_name"
#define TWITTER_PROFILE_IMAGE_URL @"profile_image_url"
#define TWITTER_BIO @"description"
#define TWITTER_ERROR @"error"

@interface ConnectionHelper : NSObject<JsonConnectionDelegate, FBRequestDelegate> {
	CFMutableDictionaryRef facebookRequestToDictionary;
}


// This class makes it a little less painful to do async calls to the Twitter API
// All callback selectors should follow the form:
//		myCallbackWithResults:(JsonResponse *)results;
// If results is nil, an error occured.

+ (void)twitter_verifyCredentialsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password;
+ (void)twitter_postTweetWithTarget:(id)target action:(SEL)action message:(NSString *)message username:(NSString *)username password:(NSString *)password;
+ (void)twitter_getFriendsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password;

+ (void)wbu_updateWithTarget:(id)target action:(SEL)action coordinate:(CLLocationCoordinate2D)coordinate;
+ (void)wbu_getUserServiceDetailsWithTarget:(id)target action:(SEL)action serviceType:(NSString *)serviceType idOnService:(NSString *)idOnService;

// facebook session must be opened for this to work.
+ (void)fb_requestWithTarget:(id)target action:(SEL)action call:(NSString *)method params:(NSDictionary *)params;


- (CFMutableDictionaryRef)facebookRequestToDictionary;

@end
