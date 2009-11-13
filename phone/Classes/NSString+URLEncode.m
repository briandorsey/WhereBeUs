//
//  NSString+URLEncode.m
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode) 

// URL encode a string 
+ (NSString *)URLEncodeString:(NSString *)string 
{ 
    NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR("% '\"?=&+<>;:-"), kCFStringEncodingUTF8); 	
    return [result autorelease]; 
} 

// Helper function 
- (NSString *)URLEncodeString 
{ 
    return [NSString URLEncodeString:self]; 
} 

@end  