//
//  UpdateAnnotation.m
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "UpdateAnnotation.h"
#import "NSDictionary+CleanObject.h"

@implementation UpdateAnnotation

@synthesize twitterUsername;
@synthesize twitterFullName;
@synthesize twitterProfileImageURL;
@synthesize message;
@synthesize lastUpdate;
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
	self.twitterUsername = nil;
	self.twitterFullName = nil;
	self.twitterProfileImageURL = nil;
	self.message = nil;
	self.lastUpdate = nil;
	[super dealloc];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
	self.twitterUsername = (NSString *)[dictionary objectForKeyOrNilIfNull:@"twitter_username"];
	self.twitterFullName = (NSString *)[dictionary objectForKeyOrNilIfNull:@"twitter_full_name"];
	self.twitterProfileImageURL = [NSURL URLWithString:(NSString *)[dictionary objectForKeyOrNilIfNull:@"twitter_profile_image_url"]];
	self.message = (NSString *)[dictionary objectForKeyOrNilIfNull:@"message"];
	coordinate.latitude = (CLLocationDegrees) [(NSNumber *)[dictionary objectForKeyOrNilIfNull:@"latitude"] doubleValue];
	coordinate.longitude = (CLLocationDegrees) [(NSNumber *)[dictionary objectForKeyOrNilIfNull:@"longitude"] doubleValue];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	self.lastUpdate = [dateFormatter dateFromString:(NSString *)[dictionary objectForKeyOrNilIfNull:@"update_datetime"]];	
}

- (NSString *)title
{
	return self.twitterFullName;
}

- (NSString *)subtitle
{
	// TODO XXX pretty print this stuff
	NSDate *now = [NSDate date];
	NSTimeInterval interval = [now timeIntervalSinceDate:self.lastUpdate];
	if (interval == 1)
	{
		return @"(1 second ago)";
	}
	else
	{
		return [NSString stringWithFormat:@"(%f seconds ago)", interval];
	}
}

@end
