//
//  TwitterService.h
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonConnection.h"

#define TWITTER_FULL_NAME @"name"
#define TWITTER_ACCOUNT_NAME @"screen_name"
#define TWITTER_PROFILE_IMAGE_URL @"profile_image_url"
#define TWITTER_BIO @"description"
#define TWITTER_ERROR @"error"

@interface TwitterService : NSObject<JsonConnectionDelegate> {

}


// This class makes it a little less painful to do async calls to the Twitter API
// All callback selectors should follow the form:
//		myCallbackWithResults:(id)results;
// If results is nil, an error occured.
// Otherwise, results is the JSON content (usually typed NSDictionary*) returned by the twitter API call.

+ (void)verifyCredentialsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password;

@end
