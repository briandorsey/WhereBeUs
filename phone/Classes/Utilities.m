//
//  Utilities.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "Utilities.h"


@implementation Utilities

+ (void)displayModalAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle delegate:(id<UIAlertViewDelegate>)delegate
{	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
						  message:message
						  delegate:delegate 
						  cancelButtonTitle:buttonTitle
						  otherButtonTitles:nil];		
	[alert show];
	[alert release];	
}


@end
