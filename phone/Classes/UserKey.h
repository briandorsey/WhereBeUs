//
//  UserKey.h
//  WhereBeUs
//
//  Created by Dave Peck on 1/11/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


// TODO davepeck: this is a stupid helper object
// I should probably have a notion of update annotation 
// that supports this but I don't right now

@interface UserKey : NSObject {}

+ (NSString *)userKeyForServiceType:(NSString *)serviceType idOnService:(NSString *)idOnService;
+ (NSString *)userKeyForUpdate:(NSDictionary *)update;

@end
