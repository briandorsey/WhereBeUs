//
//  LoginViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "LoginViewController.h"
#include "WhereBeUsAppDelegate.h"

const NSUInteger FacebookSection = 0;
const NSUInteger TwitterSection = 1;
const NSUInteger LoginInfoRow = 0;
const NSUInteger LoginActionRow = 1;

@implementation LoginViewController

@synthesize tableView;
@synthesize doneButton;

- (void)showFacebookCredentials
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
	FBSession *session = [appDelegate facebookSession];
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
	[dialog show];	
}

- (void)showTwitterCredentials
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
	[appDelegate showTwitterCredentialsController];	
}

- (void)viewDidLoad 
{	
	[super viewDidLoad];
	self.navigationItem.title = @"Accounts";
	self.navigationItem.rightBarButtonItem = self.doneButton;
	[self.doneButton setEnabled:NO];	
}

- (void)doneButtonPressed:(id)sender
{
	NSLog(@"DONE BUTTON TODO DAVEPECK");
}

- (void)dealloc 
{
	self.tableView = nil;
	self.doneButton = nil;
    [super dealloc];
}


//-----------------------------------------------------------------------
// UITableViewDelegate
//-----------------------------------------------------------------------

- (NSIndexPath *)tableView:(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath indexAtPosition:1];

	if (row == LoginActionRow)
	{
		return indexPath;
	}
	else
	{	
		return nil;
	}
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	NSUInteger section = [indexPath indexAtPosition:0];
	
	if (section == FacebookSection)
	{
		[self showFacebookCredentials];
	}
	else if (section == TwitterSection)
	{
		[self showTwitterCredentials];
	}
}


//-----------------------------------------------------------------------
// UITableViewDataSource
//-----------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == FacebookSection)
	{
		return @"Facebook";
	}
	else if (section == TwitterSection)
	{
		return @"Twitter";
	}
	
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// both facebook and twitter have two...
	return 2;
} 

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	NSUInteger section = [indexPath indexAtPosition:0];
	NSUInteger row = [indexPath indexAtPosition:1];
	
	NSString *reuseIdentifier= [NSString stringWithFormat:@"login-cell-%d-%d", section, row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];	
	if (cell != nil)
	{
		return cell;
	}
	
	cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];

	if (section == FacebookSection)
	{
		if (row == LoginInfoRow)
		{			
			cell.textLabel.text = @"not signed in";
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
			cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
		}		
		else if (row == LoginActionRow)
		{
			cell.textLabel.text = @"Sign In";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if (section == TwitterSection)
	{
		if (row == LoginInfoRow)
		{
			cell.textLabel.text = @"not signed in";
			cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
			cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
		}
		else if (row == LoginActionRow)
		{
			cell.textLabel.text = @"Sign In";
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	
	return cell;
}

@end
