//
//  TweetSpotWindow.h
//  TweetSpot
//
//  Created by Dave Peck on 10/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TweetSpotWindowDelegate;

@interface TweetSpotWindow : UIWindow {
	id<TweetSpotWindowDelegate> windowDelegate;
}

- (void)setWindowDelegate:(id<TweetSpotWindowDelegate>)theWindowDelegate;

@end


@protocol TweetSpotWindowDelegate<NSObject>
- (void)gotWindowEvent:(UIEvent *)event;
@end

