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

#define TWITTER_FULL_NAME @"name"
#define TWITTER_ACCOUNT_NAME @"screen_name"
#define TWITTER_PROFILE_IMAGE_URL @"profile_image_url"
#define TWITTER_BIO @"description"
#define TWITTER_ERROR @"error"

@interface ConnectionHelper : NSObject<JsonConnectionDelegate> {

}


// This class makes it a little less painful to do async calls to the Twitter API
// All callback selectors should follow the form:
//		myCallbackWithResults:(JsonResponse *)results;
// If results is nil, an error occured.

+ (void)twitter_verifyCredentialsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password;

+ (void)twitter_postTweetWithTarget:(id)target action:(SEL)action message:(NSString *)message username:(NSString *)username password:(NSString *)password;

+ (void)wbu_getUpdatesForHashtagWithTarget:(id)target action:(SEL)action hashtag:(NSString *)hashtag;

+ (void)wbu_postUpdateWithTarget:(id)target 
						 action:(SEL)action
				twitterUsername:(NSString *)twitterUsername 
				twitterFullName:(NSString *)twitterFullName 
		 twitterProfileImageURL:(NSString *)twitterProfileImageURL
						hashtag:(NSString *)hashtag 
						message:(NSString *)message
					 coordinate:(CLLocationCoordinate2D)coordinate;

@end
