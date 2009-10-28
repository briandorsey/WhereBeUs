//
//  JsonResult.h
//  WalkScore
//
//  Created by Dave Peck on 5/22/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JsonResponse : NSObject {
	NSArray *array;
	NSDictionary *dictionary;
}

+ (id)jsonResponseWithString:(id)jsonString; /* nil indicates failure */
- (id)initWithString:(id)jsonString;

- (BOOL)isArray;
- (BOOL)isDictionary;

- (NSArray *)array;
- (NSDictionary *)dictionary;

@end
