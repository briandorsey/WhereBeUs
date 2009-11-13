//
//  NSString+PostData.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "NSString+PostData.h"


@implementation NSString (PostData) 
+ (NSData *)postDataFromString:(NSString *)string
{
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)postData
{
	return [NSString postDataFromString:self];
}
@end