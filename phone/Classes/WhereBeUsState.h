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
	BOOL hasEverSentMessage;
	
	TwitterId twitterUserId;
	NSString *twitterUsername;
	NSString *twitterPassword;
	NSString *twitterDisplayName;
	NSString *twitterProfileImageURL;	
	NSString *twitterLargeProfileImageURL;
	NSString *twitterServiceURL;
	NSArray *twitterFollowerIds;
	
	// these are for convenience -- but they must be kept 
	// in sync with the actual fb login/logout state.
	FBUID facebookUserId;
	NSString *facebookDisplayName;
	NSString *facebookProfileImageURL;
	NSString *facebookLargeProfileImageURL;
	NSString *facebookServiceURL;
	NSArray *facebookFollowerIds;
	BOOL hasFacebookStatusUpdatePermission;
	
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

- (BOOL)hasEverSentMessage;
- (void)setHasEverSentMessage:(BOOL)newHasEverSentMessage;

// current name and profile image (preference is for twitter if both twitter and facebook are logged in)
- (NSString *)preferredDisplayName;
- (NSString *)preferredProfileImageURL;
- (NSString *)preferredLargeProfileImageURL;
- (NSString *)preferredServiceURL;
- (NSString *)preferredServiceType;
- (NSString *)preferredServiceId;
- (NSString *)preferredUserKey;

// fine-grained credential information
- (TwitterId)twitterUserId;
- (NSString *)twitterUsername;
- (NSString *)twitterPassword;
- (NSString *)twitterDisplayName;
- (NSString *)twitterProfileImageURL;
- (NSString *)twitterLargeProfileImageURL;
- (NSString *)twitterServiceURL;
- (NSArray *)twitterFollowerIds;

- (FBUID)facebookUserId;
- (NSString *)facebookDisplayName;
- (NSString *)facebookProfileImageURL;
- (NSString *)facebookLargeProfileImageURL;
- (NSString *)facebookServiceURL;
- (BOOL)hasFacebookStatusUpdatePermission;
- (NSArray *)facebookFollowerIds;

- (NSString *)lastMessage;

// you must set your credentials all-at-once
- (void)setTwitterUserId:(TwitterId)newTwitterUserId 
				username:(NSString *)newTwitterUsername 
				password:(NSString *)newTwitterPassword 
			 displayName:(NSString *)newTwitterDisplayName 
		 profileImageURL:(NSString *)newTwitterProfileImageURL
	largeProfileImageURL:(NSString *)newTwitterLargeProfileImageURL
			  serviceURL:(NSString *)newTwitterServiceURL;

- (void)setTwitterFollowerIds:(NSArray *)newTwitterFollowerIds;

- (void)setFacebookUserId:(FBUID)newFacebookUserId 
			  displayName:(NSString *)newFacebookDisplayName 
		  profileImageURL:(NSString *)newFacebookProfileImageURL
	 largeProfileImageURL:(NSString *)newFacebookLargeProfileImageURL
			   serviceURL:(NSString *)newFacebookServiceURL;

- (void)setFacebookFollowerIds:(NSArray *)newFacebookFollowerIds;

- (void)setHasFacebookStatusUpdatePermission:(BOOL)newHasFacebookStatusUpdatePermission;
- (void)setLastMessage:(NSString *)newLastMessage;
- (void)clearTwitterCredentials;
- (void)clearFacebookCredentials;

@end
