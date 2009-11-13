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

@interface WhereBeUsState : NSObject<NSCoding, NSCopying> {
	NSString *twitterUsername;
	NSString *twitterPassword;
	NSString *twitterFullName;
	NSString *twitterProfileImageURL;
	NSString *currentHashtag;
	NSString *currentMessage;
	
	BOOL isDirty;
}

+ (WhereBeUsState *)shared;

- (BOOL)isDirty;
- (void)save;

- (BOOL)hasTwitterCredentials;

- (NSString *)twitterUsername;
- (NSString *)twitterPassword;
- (NSString *)twitterFullName;
- (NSString *)twitterProfileImageURL;
- (NSString *)currentHashtag;
- (NSString *)currentMessage;

- (void)setTwitterUsername:(NSString *)newTwitterUsername;
- (void)setTwitterPassword:(NSString *)newTwitterPassword;
- (void)setTwitterFullName:(NSString *)newTwitterFullName;
- (void)setTwitterProfileImageURL:(NSString *)newTwitterProfileImageURL;
- (void)setCurrentHashtag:(NSString *)newCurrentHashtag;
- (void)setCurrentMessage:(NSString *)newCurrentMessage;

@end
