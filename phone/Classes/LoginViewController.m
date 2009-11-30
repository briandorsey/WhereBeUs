//
//  LoginViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "LoginViewController.h"
#include "WhereBeUsAppDelegate.h"

@implementation LoginViewController

@synthesize helpMessage;

@synthesize facebookButton;
@synthesize facebookStatus;
@synthesize facebookAccount;

@synthesize twitterButton;
@synthesize twitterStatus;
@synthesize twitterAccount;

- (IBAction)facebookButtonPressed:(id)sender
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
	FBSession *session = [appDelegate facebookSession];
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
	[dialog show];	
}

- (IBAction)twitterButtonPressed:(id)sender
{
}

- (void)viewDidLoad 
{	
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
}

- (void)viewDidUnload 
{
}

- (void)dealloc 
{
	self.helpMessage = nil;
	self.facebookButton = nil;
	self.facebookStatus = nil;
	self.facebookAccount = nil;
	self.twitterButton = nil;
	self.twitterStatus = nil;
	self.twitterAccount = nil;
    [super dealloc];
}

@end
