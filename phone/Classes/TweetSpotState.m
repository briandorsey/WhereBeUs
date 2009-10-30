//
//  TweetSpotState.m
//  TweetSpot
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "TweetSpotState.h"

static NSString *const kTweetSpotStateFileName = @"tweetspot.state";

static NSString *const kTwitterUsernameKey = @"twitter_username";
static NSString *const kTwitterPasswordKey = @"twitter_password";
static NSString *const kCurrentHashtagKey = @"current_hashtag";
static NSString *const kCurrentMessageKey = @"current_message";


@implementation TweetSpotState

#pragma mark Read/Write State File

+ (NSString *)filePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];	
	return [documentsDirectory stringByAppendingPathComponent:kTweetSpotStateFileName];
}

+ (TweetSpotState *)attemptToReadStateFile
{
	id state_id = nil;
	
	@try
	{
		state_id = [NSKeyedUnarchiver unarchiveObjectWithFile:[TweetSpotState filePath]];
	}
	@catch (id exception)
	{
		// the NSInvalidArgumentException is raised if the archive file is invalid.
		// if the file simply isn't there, no exception is raised
		// but the return value of [unarchiveObjectWithFile] is nil.
		state_id = nil;
	}
	
	// Did we get anything back?
	if (state_id == nil)
	{
		return nil;
	}
	
	// Did we get back an expected type?
	if (![state_id isKindOfClass:[TweetSpotState class]])
	{
		return nil;
	}
	
	// Success!
	return [((TweetSpotState *)state_id) retain];
}

+ (TweetSpotState *)getDefaultState
{
	return [[TweetSpotState alloc] init];
}

+ (id)shared
{
	static TweetSpotState *_shared;
	
	@synchronized (self)
	{
		if (_shared == nil)
		{
			_shared = [TweetSpotState attemptToReadStateFile];
			if (_shared == nil)
			{
				_shared = [TweetSpotState getDefaultState];
			}
		}		
	}
	
	return _shared;
}

- (void)saveStateFile
{
	@try
	{
		[NSKeyedArchiver archiveRootObject:self toFile:[TweetSpotState filePath]];
	}
	@catch (id exception)
	{
		// no-op -- not the end of the world if we fail to save state 
		// (though definitely SURPRISING!)
	}
}

- (void)propertyChanged
{
	// I originally just had this mark dirty, and had a separate
	// "save" routine -- but this is probably easier overall.
	[self saveStateFile];
}

#pragma mark Init/Dealloc

- (void)setDefaults
{
	twitterUsername = nil;
	twitterPassword = nil;
	currentHashtag = nil;
	currentMessage = nil;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setDefaults];
	}
	return self;
}

- (void)dealloc
{	
	[twitterUsername release];
	[twitterPassword release];
	[currentHashtag release];
	[currentMessage release];
	[super dealloc];
}

#pragma mark Properties

- (BOOL)hasTwitterCredentials
{
	return (twitterUsername != nil) && (twitterPassword != nil);
}

- (BOOL)hasHashtag
{
	return (currentHashtag != nil);
}

- (BOOL)hasMessage
{
	return (currentMessage != nil);
}

- (NSString *)twitterUsername
{
	return twitterUsername;
}

- (NSString *)twitterPassword
{
	return twitterPassword;
}

- (NSString *)currentHashtag
{
	return currentHashtag;
}

- (NSString *)currentMessage
{
	return currentMessage;
}

- (void)setTwitterUsername:(NSString *)newTwitterUsername
{
	[twitterUsername autorelease];
	twitterUsername = [newTwitterUsername retain];
	[self propertyChanged];
}

- (void)setTwitterPassword:(NSString *)newTwitterPassword
{
	[twitterPassword autorelease];
	twitterPassword = [newTwitterPassword retain];
	[self propertyChanged];
}

- (void)setCurrentHashtag:(NSString *)newCurrentHashtag
{
	[currentHashtag autorelease];
	currentHashtag = [newCurrentHashtag retain];
	
	// the current message only applies to the current hashtag
	[currentMessage autorelease];
	currentMessage = nil;

	[self propertyChanged];
}

- (void)setCurrentMessage:(NSString *)newCurrentMessage
{
	[currentMessage autorelease];
	currentMessage = [newCurrentMessage retain];
	[self propertyChanged];
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeObject:twitterUsername forKey:kTwitterUsernameKey];
	[encoder encodeObject:twitterPassword forKey:kTwitterPasswordKey];
	[encoder encodeObject:currentHashtag forKey:kCurrentHashtagKey];
	[encoder encodeObject:currentMessage forKey:kCurrentMessageKey];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
	self = [super init];
	
	if (self != nil) 
	{
		[self setDefaults];
		self.twitterUsername = [decoder decodeObjectForKey:kTwitterUsernameKey];
		self.twitterPassword = [decoder decodeObjectForKey:kTwitterPasswordKey];
		self.currentHashtag = [decoder decodeObjectForKey:kCurrentHashtagKey];
		self.currentMessage = [decoder decodeObjectForKey:kCurrentMessageKey];
	}
	
	return self;
}

#pragma mark NSCopying Implementation

- (id)copyWithZone:(NSZone *)zone 
{
	TweetSpotState *copy = [[[self class] allocWithZone:zone] init];
	
	copy.twitterUsername = [[twitterUsername copy] autorelease];
	copy.twitterPassword = [[twitterPassword copy] autorelease];
	copy.currentHashtag = [[currentHashtag copy] autorelease];
	copy.currentMessage = [[currentMessage copy] autorelease];
	
	return copy;
}

@end
