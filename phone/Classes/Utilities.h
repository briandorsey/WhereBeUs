//
//  Utilities.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utilities : NSObject {

}

+ (void)displayModalAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle delegate:(id<UIAlertViewDelegate>)delegate;

@end
