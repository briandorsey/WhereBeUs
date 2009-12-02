//
//  WhereBeUsState.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


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
	NSString *lastMessage;	
	BOOL isDirty;
}

+ (WhereBeUsState *)shared;

- (BOOL)isDirty;
- (void)save;

- (BOOL)hasTwitterCredentials;

- (TwitterId)twitterUserId;
- (NSString *)twitterUsername;
- (NSString *)twitterPassword;
- (NSString *)twitterFullName;
- (NSString *)twitterProfileImageURL;
- (NSString *)lastMessage;

- (void)setTwitterUserId:(TwitterId)twitterUserId;
- (void)setTwitterUsername:(NSString *)newTwitterUsername;
- (void)setTwitterPassword:(NSString *)newTwitterPassword;
- (void)setTwitterFullName:(NSString *)newTwitterFullName;
- (void)setTwitterProfileImageURL:(NSString *)newTwitterProfileImageURL;
- (void)setLastMessage:(NSString *)newLastMessage;

@end
