//
//  NSString+URLEncode.h
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (URLEncode) 
	+ (NSString *)URLEncodeString:(NSString *)string; 
	- (NSString *)URLEncodeString; 
@end  