//
//  TwitterCredentialsController.m
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "TwitterCredentialsController.h"
#import "ConnectionHelper.h"
#import "Utilities.h"
#import "JsonResponse.h"

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
@synthesize activityIndicator;


- (void)startLoginProcess
{
	[self disableLoginButton];
	[self.usernameField setEnabled:NO];
	[self.passwordField setEnabled:NO];
	[self.activityIndicator startAnimating];	
}

- (void)stopLoginProcess
{
	[self enableLoginButton];
	[self.usernameField setEnabled:YES];
	[self.passwordField setEnabled:YES];
	[self.activityIndicator stopAnimating];	
}

- (void)verifyCredentials_returned:(JsonResponse *)results
{
	[self stopLoginProcess];
	
	if (results == nil)
	{
		[Utilities displayModalAlertWithTitle:@"Network Error" message:@"We couldn't contact Twitter. Please check your network connection and try again." buttonTitle:@"OK"];
		return;
	}
	
	if (![results isDictionary])
	{
		[Utilities displayModalAlertWithTitle:@"Twitter Error" message:@"Twitter returned an unexpected response. Please try again." buttonTitle:@"OK"];
		return;
	}
	
	NSDictionary *dictionary = [results dictionary];
	
	NSString *error = [dictionary valueForKey:TWITTER_ERROR];
	if (error != nil)
	{
		[Utilities displayModalAlertWithTitle:@"Invalid" message:@"Either your username or your password was incorrect. Please try again." buttonTitle:@"OK"];
		return;
	}
	
	NSString *bio = [dictionary valueForKey:TWITTER_BIO];
	[Utilities displayModalAlertWithTitle:@"Your Bio" message:bio buttonTitle:@"OK"];
}

- (IBAction)loginButtonPushed:(id)sender
{
	[self startLoginProcess];
	[ConnectionHelper verifyCredentialsWithTarget:self action:@selector(verifyCredentials_returned:) username:[self.usernameField text] password:[self.passwordField text]];	
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
	self.activityIndicator = nil;
    [super dealloc];
}


@end
