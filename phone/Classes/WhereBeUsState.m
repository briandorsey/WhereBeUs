//
//  WhereBeUsState.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/30/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "WhereBeUsState.h"

static NSString *const kWhereBeUsStateFileName = @"wherebeus.state";
static NSString *const kTwitterUserIdKey = @"twitter_user_id";
static NSString *const kTwitterUsernameKey = @"twitter_username";
static NSString *const kTwitterPasswordKey = @"twitter_password";
static NSString *const kTwitterFullNameKey = @"twitter_full_name";
static NSString *const kTwitterFriendIdsKey = @"twitter_friend_ids";
static NSString *const kTwitterProfileImageURLKey = @"twitter_profile_image_url";
static NSString *const kFacebookUserIdKey = @"facebook_user_id";
static NSString *const kFacebookFullNameKey = @"facebook_full_name";
static NSString *const kFacebookProfileImageURLKey = @"facebook_profile_image_url";
static NSString *const kHasFacebookStatusUpdatePermissionKey = @"has_facebook_status_update_permission";
static NSString *const kFacebookFriendIdsKey = @"facebook_friend_ids";
static NSString *const kLastMessageKey = @"last_message";

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

#pragma mark NSNotification-related stuff

- (void)sendCredentialsNotification
{
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:CREDENTIALS_CHANGED object:self userInfo:nil];
}

- (void)sendTwitterCredentialsNotification
{
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:TWITTER_CREDENTIALS_CHANGED object:self userInfo:nil];
	[self sendCredentialsNotification];
}

- (void)sendFacebookCredentialsNotification
{
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter postNotificationName:FACEBOOK_CREDENTIALS_CHANGED object:self userInfo:nil];	
	[self sendCredentialsNotification];
}

#pragma mark Init/Dealloc

- (void)setDefaults
{
	twitterUserId = (TwitterId) 0;
	twitterUsername = nil;
	twitterPassword = nil;
	twitterFullName = nil;
	twitterProfileImageURL = nil;
	facebookUserId = (FBUID) 0;
	facebookFullName = nil;
	facebookProfileImageURL = nil;
	hasFacebookStatusUpdatePermission = NO;
	twitterFriendIds = nil;
	facebookFriendIds = nil;
	lastMessage = nil;
	isDirty = NO;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setDefaults];
		twitterFriendIds = [[NSArray array] retain];
		facebookFriendIds = [[NSArray array] retain];
	}
	return self;
}

- (void)dealloc
{	
	[twitterUsername release];
	[twitterPassword release];
	[twitterFullName release];
	[twitterProfileImageURL release];
	[facebookFullName release];
	[facebookProfileImageURL release];
	[lastMessage release];
	[twitterFriendIds release];
	[facebookFriendIds release];
	[super dealloc];
}

#pragma mark Properties

- (BOOL)isDirty
{
	return isDirty;
}

// basic helpers
- (BOOL)hasAnyCredentials
{
	return self.hasTwitterCredentials || self.hasFacebookCredentials;
}

- (BOOL)hasTwitterCredentials
{
	return (twitterUserId != (TwitterId) 0);
}

- (BOOL)hasFacebookCredentials
{
	return (facebookUserId != (FBUID) 0);
}

// current name and profile image (preference is for twitter if both twitter and facebook are logged in)
- (NSString *)preferredFullName
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterFullName;
	}
	
	return self.facebookFullName;
}

- (NSString *)preferredProfileImageURL
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterProfileImageURL;
	}
	
	return self.facebookProfileImageURL;
}

// fine-grained credential information
- (TwitterId)twitterUserId
{
	return twitterUserId;
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

- (NSArray *)twitterFriendIds
{
	return twitterFriendIds;
}

- (FBUID)facebookUserId
{
	return facebookUserId;
}

- (NSString *)facebookFullName
{
	return facebookFullName;
}

- (NSString *)facebookProfileImageURL
{
	return facebookProfileImageURL;
}

- (BOOL)hasFacebookStatusUpdatePermission
{
	return hasFacebookStatusUpdatePermission;
}

- (NSArray *)facebookFriendIds
{
	return facebookFriendIds;
}

- (NSString *)lastMessage
{
	return lastMessage;
}


#pragma mark Property Setters

- (void)setTwitterUserId:(TwitterId)newTwitterUserId username:(NSString *)newTwitterUsername password:(NSString *)newTwitterPassword fullName:(NSString *)newTwitterFullName profileImageURL:(NSString *)newTwitterProfileImageURL
{
	twitterUserId = newTwitterUserId;
	[twitterUsername autorelease];
	twitterUsername = [newTwitterUsername retain];
	[twitterPassword autorelease];
	twitterPassword = [newTwitterPassword retain];
	[twitterFullName autorelease];
	twitterFullName = [newTwitterFullName retain];
	[twitterProfileImageURL autorelease];
	twitterProfileImageURL = [newTwitterProfileImageURL retain];

	[twitterFriendIds autorelease];
	twitterFriendIds = [[NSArray array] retain];
	
	[self propertyChanged];
	[self sendTwitterCredentialsNotification];
}

- (void)setTwitterFriendIds:(NSArray *)newTwitterFriendIds
{
	[twitterFriendIds autorelease];
	twitterFriendIds = [newTwitterFriendIds retain];
}

- (void)setFacebookUserId:(FBUID)newFacebookUserId fullName:(NSString *)newFacebookFullName profileImageURL:(NSString *)newFacebookProfileImageURL
{
	facebookUserId = newFacebookUserId;
	[facebookFullName autorelease];
	facebookFullName = [newFacebookFullName retain];
	[facebookProfileImageURL autorelease];
	facebookProfileImageURL = [newFacebookProfileImageURL retain];

	hasFacebookStatusUpdatePermission = NO; /* Any time credentials change, we don't have this permission... */
	[facebookFriendIds autorelease];
	facebookFriendIds = [[NSArray array] retain];
	
	[self propertyChanged];
	[self sendFacebookCredentialsNotification];
}

- (void)setHasFacebookStatusUpdatePermission:(BOOL)newHasFacebookStatusUpdatePermission
{
	hasFacebookStatusUpdatePermission = newHasFacebookStatusUpdatePermission;
	[self propertyChanged];
}

- (void)setFacebookFriendIds:(NSArray *)newFacebookFriendIds
{
	[facebookFriendIds autorelease];
	facebookFriendIds = [newFacebookFriendIds retain];
}

- (void)clearTwitterCredentials
{
	[self setTwitterUserId:(TwitterId)0 username:nil password:nil fullName:nil profileImageURL:nil];
}

- (void)clearFacebookCredentials
{
	[self setFacebookUserId:(FBUID)0 fullName:nil profileImageURL:nil];
}

- (void)setLastMessage:(NSString *)newLastMessage
{
	[lastMessage autorelease];
	lastMessage = [newLastMessage retain];
	[self propertyChanged];
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)encoder 
{
	[encoder encodeInt32:(int32_t)twitterUserId forKey:kTwitterUserIdKey];
	[encoder encodeObject:twitterUsername forKey:kTwitterUsernameKey];
	[encoder encodeObject:twitterPassword forKey:kTwitterPasswordKey];
	[encoder encodeObject:twitterFullName forKey:kTwitterFullNameKey];
	[encoder encodeObject:twitterProfileImageURL forKey:kTwitterProfileImageURLKey];
	[encoder encodeObject:twitterFriendIds forKey:kTwitterFriendIdsKey];
	[encoder encodeInt64:(int64_t)facebookUserId forKey:kFacebookUserIdKey];
	[encoder encodeObject:facebookFullName forKey:kFacebookFullNameKey];
	[encoder encodeObject:facebookProfileImageURL forKey:kFacebookProfileImageURLKey];
	[encoder encodeObject:facebookFriendIds forKey:kFacebookFriendIdsKey];
	[encoder encodeBool:hasFacebookStatusUpdatePermission forKey:kHasFacebookStatusUpdatePermissionKey];
	[encoder encodeObject:lastMessage forKey:kLastMessageKey];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
	self = [super init];
	
	if (self != nil) 
	{
		[self setDefaults];
		twitterUserId = (TwitterId) [decoder decodeInt32ForKey:kTwitterUserIdKey];
		twitterUsername = [[decoder decodeObjectForKey:kTwitterUsernameKey] retain];
		twitterPassword = [[decoder decodeObjectForKey:kTwitterPasswordKey] retain];
		twitterFullName = [[decoder decodeObjectForKey:kTwitterFullNameKey] retain];
		twitterProfileImageURL = [[decoder decodeObjectForKey:kTwitterProfileImageURLKey] retain];
		twitterFriendIds = [[decoder decodeObjectForKey:kTwitterFriendIdsKey] retain];
		facebookUserId = (FBUID) [decoder decodeInt64ForKey:kFacebookUserIdKey];
		facebookFullName = [[decoder decodeObjectForKey:kFacebookFullNameKey] retain];
		facebookProfileImageURL = [[decoder decodeObjectForKey:kFacebookProfileImageURLKey] retain];
		facebookFriendIds = [[decoder decodeObjectForKey:kFacebookFriendIdsKey] retain];
		hasFacebookStatusUpdatePermission = [decoder decodeBoolForKey:kHasFacebookStatusUpdatePermissionKey];
		lastMessage = [[decoder decodeObjectForKey:kLastMessageKey] retain];
	}
	
	return self;
}

#pragma mark NSCopying Implementation

- (id)copyWithZone:(NSZone *)zone 
{
	WhereBeUsState *copy = [[[self class] allocWithZone:zone] init];
	
	[copy setTwitterUserId:twitterUserId
				  username:[[twitterUsername copy] autorelease]
				  password:[[twitterPassword copy] autorelease]
				  fullName:[[twitterFullName copy] autorelease]
		   profileImageURL:[[twitterProfileImageURL copy] autorelease]];
	[copy setTwitterFriendIds:[[twitterFriendIds copy] autorelease]];
	
	[copy setFacebookUserId:facebookUserId
				   fullName:[[facebookFullName copy] autorelease]
			profileImageURL:[[facebookProfileImageURL copy] autorelease]];
	[copy setFacebookFriendIds:[[facebookFriendIds copy] autorelease]];
	[copy setHasFacebookStatusUpdatePermission:hasFacebookStatusUpdatePermission];
	
	copy.lastMessage = [[lastMessage copy] autorelease];	
	return copy;
}

@end
