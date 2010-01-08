//
//  UpdateAnnotation.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "UpdateAnnotation.h"
#import "NSDictionary+CleanObject.h"

@implementation UpdateAnnotation

@synthesize displayName;
@synthesize profileImageURL;
@synthesize largeProfileImageURL;
@synthesize serviceType;
@synthesize serviceURL;
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
	self.displayName = nil;
	self.profileImageURL = nil;
	self.largeProfileImageURL = nil;
	self.serviceType = nil;
	self.serviceURL = nil;
	self.message = nil;
	self.lastUpdate = nil;
	[super dealloc];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
	self.displayName = (NSString *)[dictionary objectForKeyOrNilIfNull:@"display_name"];
	self.profileImageURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"profile_image_url"];
	self.largeProfileImageURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"large_profile_image_url"];
	self.serviceType = (NSString *)[dictionary objectForKeyOrNilIfNull:@"service_type"];
	self.serviceURL = (NSString *)[dictionary objectForKeyOrNilIfNull:@"service_url"];
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
}

- (NSString *)title
{
	return self.displayName;
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
		if (minutes == 1)
		{
			return @"1 minute ago";
		}
		else
		{			
			return [NSString stringWithFormat:@"%d minutes ago", minutes];
		}
	}
	else if (interval < 86400.0)
	{
		int hours = (int) (long int) lround(interval / 3600.0);
		if (hours == 1)
		{
			return @"1 hour ago";
		}
		else
		{
			return [NSString stringWithFormat:@"%d hours ago", hours];
		}
	}
	else if (interval < 604800.0)
	{
		int days = (int) (long int) lround(interval / 86400.0);
		if (days == 1)
		{
			return @"1 day ago";
		}
		else 
		{
			return [NSString stringWithFormat:@"%d days ago", days];
		}
	}
	else if (interval < 2419200.0)
	{
		int weeks = (int) (long int) lround(interval / 604800.0);
		if (weeks == 1)
		{
			return @"1 week ago";
		}
		else 
		{
			return [NSString stringWithFormat:@"%d weeks ago", weeks];
		}
	}
	else
	{
		return @"more than a month ago";
	}
}

- (NSString *)subtitle
{
	NSDate *now = [NSDate date];
	NSTimeInterval interval = [now timeIntervalSinceDate:self.lastUpdate];
	return [NSString stringWithFormat:@"(updated %@)", [UpdateAnnotation prettyPrintInterval:interval]];
}

- (void)setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
	coordinate.latitude = latitude;
	coordinate.longitude = longitude;
}
@end
