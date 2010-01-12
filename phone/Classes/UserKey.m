//
//  UserKey.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/11/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "UserKey.h"


@implementation UserKey

+ (NSString *)userKeyForServiceType:(NSString *)serviceType idOnService:(NSString *)idOnService
{
	// TODO davepeck: move this method somewhere sensible
	NSLog(@"Generating key for us-%@-%@", serviceType, idOnService);
	if (idOnService == nil)
	{
		NSLog(@"ALARMING");
	}
	return [NSString stringWithFormat:@"us-%@-%@", serviceType, idOnService];
}

+ (NSString *)userKeyForUpdate:(NSDictionary *)update
{
	// TODO davepeck: move this method somewhere sensible
	return [UserKey userKeyForServiceType:[update objectForKey:@"service_type"] idOnService:[update objectForKey:@"id_on_service"]];
}

@end
