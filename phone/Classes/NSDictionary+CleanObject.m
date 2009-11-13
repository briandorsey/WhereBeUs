//
//  NSDictionary+CleanObject.m
//  TweetSpot
//
//  Created by Dave Peck on 11/4/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "NSDictionary+CleanObject.h"


@implementation NSDictionary (CleanObject)

- (id)objectForKeyOrNilIfNull:(id)key
{
	id object = [self objectForKey:key];
	if (object == [NSNull null])
	{
		object = nil;
	}
	return object;	
}

@end
