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
static NSString *const kTwitterDisplayNameKey = @"twitter_display_name";
static NSString *const kTwitterFriendIdsKey = @"twitter_friend_ids";
static NSString *const kTwitterProfileImageURLKey = @"twitter_profile_image_url";
static NSString *const kTwitterLargeProfileImageURLKey = @"twitter_large_profile_image_url";
static NSString *const kTwitterServiceURLKey = @"twitter_service_url";
static NSString *const kFacebookUserIdKey = @"facebook_user_id";
static NSString *const kFacebookDisplayNameKey = @"facebook_display_name";
static NSString *const kFacebookProfileImageURLKey = @"facebook_profile_image_url";
static NSString *const kFacebookLargeProfileImageURLKey = @"facebook_large_profile_image_url";
static NSString *const kFacebookServiceURLKey = @"facebook_service_url";
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
	twitterDisplayName = nil;
	twitterProfileImageURL = nil;
	twitterLargeProfileImageURL = nil;
	twitterServiceURL = nil;
	facebookUserId = (FBUID) 0;
	facebookDisplayName = nil;
	facebookProfileImageURL = nil;
	facebookLargeProfileImageURL = nil;
	facebookServiceURL = nil;
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
	[twitterDisplayName release];
	[twitterProfileImageURL release];
	[twitterLargeProfileImageURL release];
	[twitterServiceURL release];
	[facebookDisplayName release];
	[facebookProfileImageURL release];
	[facebookLargeProfileImageURL release];
	[facebookServiceURL release];
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
- (NSString *)preferredDisplayName
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterDisplayName;
	}
	
	return self.facebookDisplayName;
}

- (NSString *)preferredProfileImageURL
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterProfileImageURL;
	}
	
	return self.facebookProfileImageURL;
}

- (NSString *)preferredLargeProfileImageURL
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterLargeProfileImageURL;
	}
	return self.facebookLargeProfileImageURL;
}

- (NSString *)preferredServiceURL
{
	if (self.hasTwitterCredentials)
	{
		return self.twitterServiceURL;
	}
	return self.facebookServiceURL;
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

- (NSString *)twitterDisplayName
{
	return twitterDisplayName;
}

- (NSString *)twitterProfileImageURL
{
	return twitterProfileImageURL;
}

- (NSString *)twitterLargeProfileImageURL
{
	return twitterLargeProfileImageURL;
}

- (NSString *)twitterServiceURL
{
	return twitterServiceURL;
}

- (NSArray *)twitterFriendIds
{
	return twitterFriendIds;
}

- (FBUID)facebookUserId
{
	return facebookUserId;
}

- (NSString *)facebookDisplayName
{
	return facebookDisplayName;
}

- (NSString *)facebookProfileImageURL
{
	return facebookProfileImageURL;
}

- (NSString *)facebookLargeProfileImageURL
{
	return facebookLargeProfileImageURL;
}

- (NSString *)facebookServiceURL
{
	return facebookServiceURL;
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

- (void)setTwitterUserId:(TwitterId)newTwitterUserId 
				username:(NSString *)newTwitterUsername 
				password:(NSString *)newTwitterPassword 
			 displayName:(NSString *)newTwitterDisplayName 
		 profileImageURL:(NSString *)newTwitterProfileImageURL
	largeProfileImageURL:(NSString *)newTwitterLargeProfileImageURL
			  serviceURL:(NSString *)newTwitterServiceURL
{
	twitterUserId = newTwitterUserId;
	[twitterUsername autorelease];
	twitterUsername = [newTwitterUsername retain];
	[twitterPassword autorelease];
	twitterPassword = [newTwitterPassword retain];
	[twitterDisplayName autorelease];
	twitterDisplayName = [newTwitterDisplayName retain];
	[twitterProfileImageURL autorelease];
	twitterProfileImageURL = [newTwitterProfileImageURL retain];
	[twitterLargeProfileImageURL autorelease];
	twitterLargeProfileImageURL = [newTwitterLargeProfileImageURL retain];
	[twitterServiceURL autorelease];
	twitterServiceURL = [newTwitterServiceURL retain];

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

- (void)setFacebookUserId:(FBUID)newFacebookUserId 
			  displayName:(NSString *)newFacebookDisplayName 
		  profileImageURL:(NSString *)newFacebookProfileImageURL
	 largeProfileImageURL:(NSString *)newFacebookLargeProfileImageURL
			   serviceURL:(NSString *)newFacebookServiceURL
{
	facebookUserId = newFacebookUserId;
	[facebookDisplayName autorelease];
	facebookDisplayName = [newFacebookDisplayName retain];
	[facebookProfileImageURL autorelease];
	facebookProfileImageURL = [newFacebookProfileImageURL retain];
	[facebookLargeProfileImageURL autorelease];
	facebookLargeProfileImageURL = [newFacebookLargeProfileImageURL retain];
	[facebookServiceURL autorelease];
	facebookServiceURL = [newFacebookServiceURL retain];

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
	[self setTwitterUserId:(TwitterId)0 username:nil password:nil displayName:nil profileImageURL:nil largeProfileImageURL:nil serviceURL:nil];
}

- (void)clearFacebookCredentials
{
	[self setFacebookUserId:(FBUID)0 displayName:nil profileImageURL:nil largeProfileImageURL:nil serviceURL:nil];
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
	[encoder encodeObject:twitterDisplayName forKey:kTwitterDisplayNameKey];
	[encoder encodeObject:twitterProfileImageURL forKey:kTwitterProfileImageURLKey];
	[encoder encodeObject:twitterLargeProfileImageURL forKey:kTwitterLargeProfileImageURLKey];
	[encoder encodeObject:twitterServiceURL forKey:kTwitterServiceURLKey];
	[encoder encodeObject:twitterFriendIds forKey:kTwitterFriendIdsKey];
	[encoder encodeInt64:(int64_t)facebookUserId forKey:kFacebookUserIdKey];
	[encoder encodeObject:facebookDisplayName forKey:kFacebookDisplayNameKey];
	[encoder encodeObject:facebookProfileImageURL forKey:kFacebookProfileImageURLKey];
	[encoder encodeObject:facebookLargeProfileImageURL forKey:kFacebookLargeProfileImageURLKey];
	[encoder encodeObject:facebookServiceURL forKey:kFacebookServiceURLKey];
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
		twitterDisplayName = [[decoder decodeObjectForKey:kTwitterDisplayNameKey] retain];
		twitterProfileImageURL = [[decoder decodeObjectForKey:kTwitterProfileImageURLKey] retain];
		twitterLargeProfileImageURL = [[decoder decodeObjectForKey:kTwitterLargeProfileImageURLKey] retain];
		twitterServiceURL = [[decoder decodeObjectForKey:kTwitterServiceURLKey] retain];
		twitterFriendIds = [[decoder decodeObjectForKey:kTwitterFriendIdsKey] retain];
		facebookUserId = (FBUID) [decoder decodeInt64ForKey:kFacebookUserIdKey];
		facebookDisplayName = [[decoder decodeObjectForKey:kFacebookDisplayNameKey] retain];
		facebookProfileImageURL = [[decoder decodeObjectForKey:kFacebookProfileImageURLKey] retain];
		facebookLargeProfileImageURL = [[decoder decodeObjectForKey:kFacebookLargeProfileImageURLKey] retain];
		facebookServiceURL = [[decoder decodeObjectForKey:kFacebookServiceURLKey] retain];
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
				  displayName:[[twitterDisplayName copy] autorelease]
		   profileImageURL:[[twitterProfileImageURL copy] autorelease]
	  largeProfileImageURL:[[twitterLargeProfileImageURL copy] autorelease]
				serviceURL:[[twitterServiceURL copy] autorelease]];
	[copy setTwitterFriendIds:[[twitterFriendIds copy] autorelease]];
	
	[copy setFacebookUserId:facebookUserId
				   displayName:[[facebookDisplayName copy] autorelease]
			profileImageURL:[[facebookProfileImageURL copy] autorelease]
	   largeProfileImageURL:[[facebookLargeProfileImageURL copy] autorelease]
				 serviceURL:[[facebookServiceURL copy] autorelease]];
	[copy setFacebookFriendIds:[[facebookFriendIds copy] autorelease]];
	[copy setHasFacebookStatusUpdatePermission:hasFacebookStatusUpdatePermission];
	
	copy.lastMessage = [[lastMessage copy] autorelease];	
	return copy;
}

@end
