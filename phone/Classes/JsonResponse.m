//
//  JsonResult.m
//  WalkScore
//
//  Created by Dave Peck on 5/22/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "JsonResponse.h"
#import "JSON.h"


@interface JsonResponse (JsonResponsePrivate)
-(void)dealloc;
@end


@implementation JsonResponse

+ (id)jsonResponseWithString:(NSString *)jsonString
{
	return [[[JsonResponse alloc] initWithString:jsonString] autorelease];
}

- (id)initWithString:(NSString *)jsonString
{
	self = [super init];
	
	if (self != nil)
	{
		id jsonObject = [jsonString JSONValue];
		
		if (jsonObject == nil)
		{
			// failure!
			[self release];
			return nil;
		}
		
		if ([jsonObject isKindOfClass:[NSArray class]])			
		{
			array = (NSArray*) [jsonObject retain];
		}
		else if ([jsonObject isKindOfClass:[NSDictionary class]])
		{
			dictionary = (NSDictionary*) [jsonObject retain];
		}		
	}
	
	return self;
}

- (BOOL)isArray
{
	return array != nil;
}

- (BOOL)isDictionary
{
	return dictionary != nil;
}

- (NSArray *)array
{
	return array;
}

- (NSDictionary *)dictionary
{
	return dictionary;
}

- (void)dealloc
{
	[array release];
	[dictionary release];
	[super dealloc];
}

@end
