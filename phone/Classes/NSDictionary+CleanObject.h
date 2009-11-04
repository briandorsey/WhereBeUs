//
//  NSDictionary+CleanObject.h
//  TweetSpot
//
//  Created by Dave Peck on 11/4/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (CleanObject)

- (id)objectForKeyOrNilIfNull:(id)key;

@end
