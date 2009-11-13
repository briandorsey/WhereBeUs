//
//  WhereBeUsWindow.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WhereBeUsWindowDelegate;

@interface WhereBeUsWindow : UIWindow {
	id<WhereBeUsWindowDelegate> windowDelegate;
}

- (void)setWindowDelegate:(id<WhereBeUsWindowDelegate>)theWindowDelegate;

@end


@protocol WhereBeUsWindowDelegate<NSObject>
- (void)gotWindowEvent:(UIEvent *)event;
@end

