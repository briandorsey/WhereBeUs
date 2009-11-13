//
//  WhereBeUsWindow.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "WhereBeUsWindow.h"


@implementation WhereBeUsWindow

- (void)setWindowDelegate:(id<WhereBeUsWindowDelegate>)theWindowDelegate
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
