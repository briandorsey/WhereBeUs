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
	self.twitterProfileImageURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"twitter_profile_image_url"];
	self.message = (NSString *)[dictionary objectForKeyOrNilIfNull:@"message"];
	coordinate.latitude = (CLLocationDegrees) [(NSNumber *)[dictionary objectForKeyOrNilIfNull:@"latitude"] doubleValue];
	coordinate.longitude = (CLLocationDegrees) [(NSNumber *)[dictionary objectForKeyOrNilIfNull:@"longitude"] doubleValue];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *update_datetime = (NSString *)[dictionary objectForKeyOrNilIfNull:@"update_datetime"];
	if (update_datetime == nil)
	{
		self.lastUpdate = nil;
	}
	else
	{
		self.lastUpdate = [dateFormatter dateFromString:update_datetime];
	}
}

- (NSString *)title
{
	return self.twitterFullName;
}

+ (NSString *)prettyPrintInterval:(NSTimeInterval)interval
{
	if (interval < 60.0)
	{
		return @"less than a minute ago";
	}
	else if (interval < 120.0)
	{
		return @"about a minute ago";
	}
	else if (interval < 180.0)
	{
		return @"a couple of minutes ago";
	}
	else if (interval < 240.0)
	{
		return @"a few minutes ago";
	}
	else if (interval < 3600.0)
	{
		int minutes = (int) (long int) lround(interval / 60.0);
		return [NSString stringWithFormat:@"%d minutes ago", minutes];
	}
	else if (interval < 86400.0)
	{
		int hours = (int) (long int) lround(interval / 3600.0);
		return [NSString stringWithFormat:@"%d hours ago", hours];
	}
	else if (interval < 604800.0)
	{
		int days = (int) (long int) lround(interval / 86400.0);
		return [NSString stringWithFormat:@"%d days ago", days];
	}
	else if (interval < 2419200.0)
	{
		int weeks = (int) (long int) lround(interval / 604800.0);
		return [NSString stringWithFormat:@"%d weeks ago", weeks];
	}
	else
	{
		return @"a very long time ago";
	}
}

- (NSString *)subtitle
{
	// TODO XXX pretty print this stuff
	NSDate *now = [NSDate date];
	NSTimeInterval interval = [now timeIntervalSinceDate:self.lastUpdate];
	return [NSString stringWithFormat:@"(last updated %@)", [UpdateAnnotation prettyPrintInterval:interval]];
}

- (void)setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	coordinate.latitude = latitude;
	coordinate.longitude = longitude;
}

@end
