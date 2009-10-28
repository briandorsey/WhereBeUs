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
// Private Stuff
//-----------------------------------------------------------------------

- (void)disableLoginButton
{
	[self.loginButton setEnabled:NO];
}

- (void)enableLoginButton
{
	[self.loginButton setEnabled:YES];
}


//-----------------------------------------------------------------------
// Outlets and Actions
//-----------------------------------------------------------------------

@synthesize usernameField;
@synthesize passwordField;
@synthesize loginButton;

- (IBAction)loginButtonPushed:(id)sender
{
	
}

- (IBAction)textChanged:(id)sender
{
	NSString *username = [self.usernameField text];
	NSString *password = [self.passwordField text];
	if (([username length] > 1) && ([password length] > 2))
	{
		[self enableLoginButton];
	}
	else
	{
		[self disableLoginButton];
	}		
}


//-----------------------------------------------------------------------
// UIViewController overrides
//-----------------------------------------------------------------------

- (void)viewDidLoad 
{
	// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
	
	[self.loginButton setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] forState:UIControlStateDisabled];
	[self disableLoginButton];
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
