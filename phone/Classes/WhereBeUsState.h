//
//  WhereBeUsState.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBConnect.h"

// catch-all place to put state that we want to save
// between runs of the application -- would normally break this
// into several model objects but this is HACK NIGHT Y'ALL!

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

- (BOOL)hasTwitterCredentials;
- (BOOL)hasFacebookCredentials;

// These return whatever is logged in, but if both are 
// logged in they return twitter (naturally!)
- (NSString *)preferredFullName;
- (NSString *)preferredProfileImageURL;
- (void)clearTwitter;
- (void)clearFacebook;

- (TwitterId)twitterUserId;
- (NSString *)twitterUsername;
- (NSString *)twitterPassword;
- (NSString *)twitterFullName;
- (NSString *)twitterProfileImageURL;
- (FBUID)facebookUserId;
- (NSString *)facebookFullName;
- (NSString *)facebookProfileImageURL;
- (NSString *)lastMessage;

- (void)setTwitterUserId:(TwitterId)twitterUserId;
- (void)setTwitterUsername:(NSString *)newTwitterUsername;
- (void)setTwitterPassword:(NSString *)newTwitterPassword;
- (void)setTwitterFullName:(NSString *)newTwitterFullName;
- (void)setTwitterProfileImageURL:(NSString *)newTwitterProfileImageURL;
- (void)setFacebookUserId:(FBUID)newFacebookUserId;
- (void)setFacebookFullName:(NSString *)newFacebookFullName;
- (void)setFacebookProfileImageURL:(NSString *)newFacebookProfileImageURL;
- (void)setLastMessage:(NSString *)newLastMessage;

@end
