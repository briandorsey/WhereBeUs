//
//  NSDictionary+PostData.m
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "NSDictionary+PostData.h"
#import "NSString+PostData.h"
#import "NSString+URLEncode.h"

@implementation NSDictionary (PostData) 
+ (NSData *)postDataFromDictionary:(NSDictionary *)dictionary
{
	NSMutableString *postString = [NSMutableString stringWithString:@""];
	
	BOOL first = YES;
	for (NSString *key in dictionary)
	{
		NSString *value = (NSString *)[dictionary objectForKey:key];
		if (!first)
		{
			[postString appendString:@"&"];
		}
		[postString appendFormat:@"%@=%@", key, [value URLEncodeString]];
		first = NO;
	}
	
	return [postString postData];	
}

- (NSData *)postData
{
	return [NSDictionary postDataFromDictionary:self];
}
@end  