//
//  TwitterUtilities.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/6/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "TwitterUtilities.h"


@implementation TwitterUtilities

+ (NSString *)largeProfileImageURLFromSmall:(NSString*)profileImageURL
{
	return [profileImageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
}

+ (NSString *)serviceURLFromScreenName:(NSString*)screenName
{
	return [NSString stringWithFormat:@"http://twitter.com/%@/", screenName];
}

@end
