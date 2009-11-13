//
//  NSDictionary+PostData.h
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (PostData) 
+ (NSData *)postDataFromDictionary:(NSDictionary *)dictionary; 
- (NSData *)postData; 
@end  