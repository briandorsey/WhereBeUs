//
//  WhereBeUsState.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "WhereBeUsState.h"

static NSString *const kWhereBeUsStateFileName = @"wherebeus.state";

static NSString *const kTwitterUsernameKey = @"twitter_username";
static NSString *const kTwitterPasswordKey = @"twitter_password";
static NSString *const kTwitterFullNameKey = @"twitter_full_name";
static NSString *const kTwitterProfileImageURLKey = @"twitter_profile_image_url";
static NSString *const kLastTweetedMessageKey = @"last_tweeted_message";


@implementation WhereBeUsState

#pragma mark Read/Write State File

+ (NSString *)filePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];	
	return [documentsDirectory stringByAppendingPathComponent:kWhereBeUsStateFileName];
}

+ (WhereBeUsState *)attemptToReadStateFile
{
	id state_id = nil;
	
	@try
	{
		state_id = [NSKeyedUnarchiver unarchiveObjectWithFile:[WhereBeUsState filePath]];
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
	if (![state_id isKindOfClass:[WhereBeUsState class]])
	{
		return nil;
	}
	
	// Success!
	return [((WhereBeUsState *)state_id) retain];
}

+ (WhereBeUsState *)getDefaultState
{
	return [[WhereBeUsState alloc] init];
}

+ (id)shared
{
	static WhereBeUsState *_shared;
	
	@synchronized (self)
	{
		if (_shared == nil)
		{
			_shared = [WhereBeUsState attemptToReadStateFile];
			if (_shared == nil)
			{
				_shared = [WhereBeUsState getDefaultState];
			}
		}		
	}
	
	return _shared;
}

- (void)save
{
	if (isDirty)
	{
		@try
		{
			[NSKeyedArchiver archiveRootObject:self toFile:[WhereBeUsState filePath]];
			isDirty = NO;
		}
		@catch (id exception)
		{
			// no-op -- not the end of the world if we fail to save state 
			// (though definitely SURPRISING!)
		}
	}
}

- (void)propertyChanged
{
	isDirty = YES;
}

#pragma mark Init/Dealloc

- (void)setDefaults
{
	twitterUsername = nil;
	twitterPassword = nil;
	twitterFullName = nil;
	twitterProfileImageURL = nil;
	lastTweetedMessage = nil;
	isDirty = NO;
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
	[twitterFullName release];
	[twitterProfileImageURL release];
	[lastTweetedMessage release];
	[super dealloc];
}

#pragma mark Properties

- (BOOL)hasTwitterCredentials
{
	return (twitterUsername != nil) && (twitterPassword != nil);
}

- (BOOL)isDirty
{
	return isDirty;
}

- (NSString *)twitterUsername
{
	return twitterUsername;
}

- (NSString *)twitterPassword
{
	return twitterPassword;
}

- (NSString *)twitterFullName
{
	return twitterFullName;
}

- (NSString *)twitterProfileImageURL
{
	return twitterProfileImageURL;
}

- (NSString *)lastTweetedMessage
{
	return lastTweetedMessage;
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

- (void)setTwitterFullName:(NSString *)newTwitterFullName
{
	[twitterFullName autorelease];
	twitterFullName = [newTwitterFullName retain];
	[self propertyChanged];
}

- (void)setTwitterProfileImageURL:(NSString *)newTwitterProfileImageURL
{
	[twitterProfileImageURL autorelease];
	twitterProfileImageURL = [newTwitterProfileImageURL retain];
	[self propertyChanged];
}

- (void)setLastTweetedMessage:(NSString *)newLastTweetedMessage
{
	[lastTweetedMessage autorelease];
	lastTweetedMessage = [newLastTweetedMessage retain];
	[self propertyChanged];
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeObject:twitterUsername forKey:kTwitterUsernameKey];
	[encoder encodeObject:twitterPassword forKey:kTwitterPasswordKey];
	[encoder encodeObject:twitterFullName forKey:kTwitterFullNameKey];
	[encoder encodeObject:twitterProfileImageURL forKey:kTwitterProfileImageURLKey];
	[encoder encodeObject:lastTweetedMessage forKey:kLastTweetedMessageKey];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
	self = [super init];
	
	if (self != nil) 
	{
		[self setDefaults];
		self.twitterUsername = [decoder decodeObjectForKey:kTwitterUsernameKey];
		self.twitterPassword = [decoder decodeObjectForKey:kTwitterPasswordKey];
		self.twitterFullName = [decoder decodeObjectForKey:kTwitterFullNameKey];
		self.twitterProfileImageURL = [decoder decodeObjectForKey:kTwitterProfileImageURLKey];
		self.lastTweetedMessage = [decoder decodeObjectForKey:kLastTweetedMessageKey];
	}
	
	return self;
}

#pragma mark NSCopying Implementation

- (id)copyWithZone:(NSZone *)zone 
{
	WhereBeUsState *copy = [[[self class] allocWithZone:zone] init];
	
	copy.twitterUsername = [[twitterUsername copy] autorelease];
	copy.twitterPassword = [[twitterPassword copy] autorelease];
	copy.twitterFullName = [[twitterFullName copy] autorelease];
	copy.twitterProfileImageURL = [[twitterProfileImageURL copy] autorelease];
	copy.lastTweetedMessage = [[lastTweetedMessage copy] autorelease];
	
	return copy;
}

@end
