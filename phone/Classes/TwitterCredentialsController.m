//
//  TwitterCredentialsController.m
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "TwitterCredentialsController.h"


@implementation TwitterCredentialsController

//-----------------------------------------------------------------------
// Outlets and Actions
//-----------------------------------------------------------------------

@synthesize usernameField;
@synthesize passwordField;
@synthesize loginButton;

- (void)loginButtonPushed:(id)sender
{
}

- (void)usernameTextChanged:(id)sender
{
}

- (void)passwordTextChanged:(id)sender
{
}


//-----------------------------------------------------------------------
// UIViewController overrides
//-----------------------------------------------------------------------

- (void)viewDidLoad 
{
	// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
	
	[self.loginButton setEnabled:NO];
	[self.loginButton setHighlighted:NO];
	[self.usernameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	self.usernameField = nil;
	self.passwordField = nil;
	self.loginButton = nil;
    [super dealloc];
}


@end
