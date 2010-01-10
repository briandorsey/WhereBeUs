//
//  NSDate+PrettyPrint.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/10/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "NSDate+PrettyPrint.h"


@implementation NSDate (PrettyPrint)

+ (NSString *)prettyPrintTimeInterval:(NSTimeInterval)interval
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

- (NSString *)prettyPrintTimeIntervalSinceDate:(NSDate *)anotherDate
{
	NSTimeInterval interval = [self timeIntervalSinceDate:anotherDate];
	return [NSDate prettyPrintTimeInterval:interval];
}

@end
