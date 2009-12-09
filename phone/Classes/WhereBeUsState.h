//
//  WhereBeUsState.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBConnect.h"

#define CREDENTIALS_CHANGED @"wherebeus_credentials_changed"
#define FACEBOOK_CREDENTIALS_CHANGED @"wherebeus_facebook_credentials_changed"
#define TWITTER_CREDENTIALS_CHANGED @"wherebeus_twitter_credentials_changed"

typedef uint32_t TwitterId; /* 4 bytes on phone, enough for 4.3 billion twitter users. Seems fair enough. */

@interface WhereBeUsState : NSObject<NSCoding, NSCopying> {
	TwitterId twitterUserId;
	NSString *twitterUsername;
	NSString *twitterPassword;
	NSString *twitterFullName;
	NSString *twitterProfileImageURL;	
	
	// these are for convenience -- but they must be kept 
	// in sync with the actual fb login/logout state.
	FBUID facebookUserId;
	NSString *facebookFullName;
	NSString *facebookProfileImageURL;
	
	NSString *lastMessage;	
	BOOL isDirty;
}

+ (WhereBeUsState *)shared;

- (BOOL)isDirty;
- (void)save;

// basic helpers
- (BOOL)hasAnyCredentials;
- (BOOL)hasTwitterCredentials;
- (BOOL)hasFacebookCredentials;

// current name and profile image (preference is for twitter if both twitter and facebook are logged in)
- (NSString *)preferredFullName;
- (NSString *)preferredProfileImageURL;

// fine-grained credential information
- (TwitterId)twitterUserId;
- (NSString *)twitterUsername;
- (NSString *)twitterPassword;
- (NSString *)twitterFullName;
- (NSString *)twitterProfileImageURL;
- (FBUID)facebookUserId;
- (NSString *)facebookFullName;
- (NSString *)facebookProfileImageURL;
- (NSString *)lastMessage;

// you must set your credentials all-at-once
- (void)setTwitterUserId:(TwitterId)newTwitterUserId username:(NSString *)newTwitterUsername password:(NSString *)newTwitterPassword fullName:(NSString *)newTwitterFullName profileImageURL:(NSString *)newTwitterProfileImageURL;
- (void)setFacebookUserId:(FBUID)newFacebookUserId fullName:(NSString *)newFacebookFullName profileImageURL:(NSString *)newFacebookProfileImageURL;
- (void)setLastMessage:(NSString *)newLastMessage;
- (void)clearTwitterCredentials;
- (void)clearFacebookCredentials;

@end
