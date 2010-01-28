//
//  UpdateAnnotation.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "UpdateAnnotation.h"
#import "NSDictionary+CleanObject.h"
#import "NSDate+PrettyPrint.h"
#import "UserKey.h"
#import "WhereBeUsState.h"

@implementation UpdateAnnotation

@synthesize screenName;
@synthesize displayName;
@synthesize profileImageURL;
@synthesize largeProfileImageURL;
@synthesize serviceType;
@synthesize serviceURL;
@synthesize idOnService;
@synthesize message;
@synthesize lastUpdate;
@synthesize lastMessageUpdate;
@synthesize coordinate;
@synthesize visited;

+ (id)updateAnnotationWithDictionary:(NSDictionary *)dictionary
{
	return [[[UpdateAnnotation alloc] initWithDictionary:dictionary] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self != nil)
	{
		[self updateWithDictionary:dictionary];
	}
	return self;
}

- (void)dealloc
{
	self.screenName = nil;
	self.displayName = nil;
	self.profileImageURL = nil;
	self.largeProfileImageURL = nil;
	self.serviceType = nil;
	self.serviceURL = nil;
	self.idOnService = nil;
	self.message = nil;
	self.lastUpdate = nil;
	self.lastMessageUpdate = nil;
	[super dealloc];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
	self.screenName = (NSString *)[dictionary objectForKeyOrNilIfNull:@"screen_name"];
	self.displayName = (NSString *)[dictionary objectForKeyOrNilIfNull:@"display_name"];
	self.profileImageURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"profile_image_url"];
	self.largeProfileImageURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"large_profile_image_url"];
	self.serviceType = (NSString *)[dictionary objectForKeyOrNilIfNull:@"service_type"];
	self.serviceURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"service_url"];
	self.idOnService = (NSString *)[dictionary objectForKeyOrNilIfNull:@"id_on_service"];
	self.message = (NSString *)[dictionary objectForKeyOrNilIfNull:@"message"];
	coordinate.latitude = (CLLocationDegrees) [(NSNumber *)[dictionary objectForKeyOrNilIfNull:@"latitude"] doubleValue];
	coordinate.longitude = (CLLocationDegrees) [(NSNumber *)[dictionary objectForKeyOrNilIfNull:@"longitude"] doubleValue];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *update_time = (NSString *)[dictionary objectForKeyOrNilIfNull:@"update_time"];
	if (update_time == nil)
	{
		self.lastUpdate = nil;
	}
	else
	{
		self.lastUpdate = [dateFormatter dateFromString:update_time];
	}
	
	NSString *message_time = (NSString *)[dictionary objectForKeyOrNilIfNull:@"message_time"];
	if (message_time == nil)
	{
		self.lastMessageUpdate = nil;
	}
	else
	{
		self.lastMessageUpdate = [dateFormatter dateFromString:message_time];
	}
}

- (NSString *)title
{
	return self.displayName;
}

- (NSString *)subtitle
{
	if (self.lastUpdate == nil)
	{
		return nil;
	}
	
	NSString *interval = [[NSDate date] prettyPrintTimeIntervalSinceDate:self.lastUpdate];
	return [NSString stringWithFormat:@"(updated %@)", interval];
}

- (void)setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	coordinate.latitude = latitude;
	coordinate.longitude = longitude;
}

- (NSString *)userKey
{
	return [UserKey userKeyForServiceType:self.serviceType idOnService:self.idOnService];
}

- (BOOL)isTwitter
{
	return [@"twitter" isEqualToString:self.serviceType];
}

- (BOOL)isFacebook
{
	return ![self isTwitter];
}

- (BOOL)isCurrentUser
{
	WhereBeUsState *state = [WhereBeUsState shared];
	return [state.preferredUserKey isEqualToString:[self userKey]];
}

@end
