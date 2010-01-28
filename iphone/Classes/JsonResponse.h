//
//  JsonResult.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
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
