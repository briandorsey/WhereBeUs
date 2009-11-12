//
//  TweetSpotWindow.m
//  TweetSpot
//
//  Created by Dave Peck on 10/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "TweetSpotWindow.h"


@implementation TweetSpotWindow

- (void)setWindowDelegate:(id<TweetSpotWindowDelegate>)theWindowDelegate
{
	windowDelegate = theWindowDelegate;
}

- (void)sendEvent:(UIEvent *)event
{
	if (windowDelegate != nil)
	{
		[windowDelegate gotWindowEvent:event];
	}

	[super sendEvent:event];
}

- (void)dealloc
{
	windowDelegate = nil;
	[super dealloc];
}

@end
