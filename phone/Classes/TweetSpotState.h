//
//  TweetSpotState.h
//  TweetSpot
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


// catch-all place to put state that we want to save
// between runs of the application -- would normally break this
// into several model objects but this is HACK NIGHT Y'ALL!

@interface TweetSpotState : NSObject<NSCoding, NSCopying> {
	NSString *twitterUsername;
	NSString *twitterPassword;
	NSString *currentHashtag;
	NSString *currentMessage;
}

+ (TweetSpotState *)shared;

- (BOOL)hasTwitterCredentials;
- (BOOL)hasHashtag;
- (BOOL)hasMessage;

- (NSString *)twitterUsername;
- (NSString *)twitterPassword;
- (NSString *)currentHashtag;
- (NSString *)currentMessage;

- (void)setTwitterUsername:(NSString *)newTwitterUsername;
- (void)setTwitterPassword:(NSString *)newTwitterPassword;
- (void)setCurrentHashtag:(NSString *)newCurrentHashtag;
- (void)setCurrentMessage:(NSString *)newCurrentMessage;

@end
