//
//  NSDate+PrettyPrint.h
//  WhereBeUs
//
//  Created by Dave Peck on 1/10/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (PrettyPrint)

+ (NSString *)prettyPrintTimeInterval:(NSTimeInterval)interval;
- (NSString *)prettyPrintTimeIntervalSinceDate:(NSDate *)anotherDate;

@end
