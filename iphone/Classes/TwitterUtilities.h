//
//  TwitterUtilities.h
//  WhereBeUs
//
//  Created by Dave Peck on 1/6/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TwitterUtilities : NSObject {

}

+ (NSString *)largeProfileImageURLFromSmall:(NSString*)profileImageURL;
+ (NSString *)serviceURLFromScreenName:(NSString*)screenName;

@end
