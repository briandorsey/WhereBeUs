//
//  LoginViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "LoginViewController.h"
#include "WhereBeUsAppDelegate.h"
#include "WhereBeUsState.h"
#include "ConnectionHelper.h"

const NSUInteger FacebookSection = 0;
const NSUInteger TwitterSection = 1;
const NSUInteger LoginInfoRow = 0;
const NSUInteger LoginActionRow = 1;

@implementation LoginViewController

@synthesize tableView;
@synthesize doneButton;

- (void)showFacebookCredentials
{
	FBSession *session = [FBSession session];
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:session] autorelease];
	[dialog show];	
}

- (void)showTwitterCredentials
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
	[[appDelegate backSideNavigationController] showTwitterCredentialsController];	
}

- (void)viewDidLoad 
{	
	[super viewDidLoad];
	self.navigationItem.title = @"Accounts";
	self.navigationItem.rightBarButtonItem = self.doneButton;
	WhereBeUsState *state = [WhereBeUsState shared];	
	[self.doneButton setEnabled:state.hasAnyCredentials];
}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(credentialsChanged:) name:CREDENTIALS_CHANGED object:nil];
	WhereBeUsState *state = [WhereBeUsState shared];	
	[self.doneButton setEnabled:state.hasAnyCredentials];
	[self.tableView reloadData];	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CREDENTIALS_CHANGED object:nil];	
	[super viewWillDisappear:animated];
}

- (void)doneButtonPressed:(id)sender
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) [UIApplication sharedApplication].delegate;
	[appDelegate flip:YES];
}

- (void)dealloc 
{
	self.tableView = nil;
	self.doneButton = nil;
    [super dealloc];
}


//-----------------------------------------------------------------------
// NSNotification Recipient
//-----------------------------------------------------------------------

- (void)credentialsChanged:(NSNotification*)notification
{
	WhereBeUsState *state = [WhereBeUsState shared];
	[self.doneButton setEnabled:state.hasAnyCredentials];
	[self.tableView reloadData];
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
	WhereBeUsState *state = [WhereBeUsState shared];
		
	if (section == FacebookSection)
	{
		if (state.hasFacebookCredentials)
		{
			FBSession *session = [FBSession session];
			[session logout];
			[state clearFacebookCredentials];
			[state save];
		}
		else
		{
			[self showFacebookCredentials];
		}
	}
	else if (section == TwitterSection)
	{
		if (state.hasTwitterCredentials)
		{
			[state clearTwitterCredentials];
			[state save];
		}
		else
		{		
			[self showTwitterCredentials];
		}
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
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	WhereBeUsState *state = [WhereBeUsState shared];

	if (section == FacebookSection)
	{
		if (state.hasFacebookCredentials)
		{
			if (row == LoginInfoRow)
			{
				cell.textLabel.text = [NSString stringWithFormat:@"signed in as %@", state.facebookFullName];
				cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
				cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
			}		
			else if (row == LoginActionRow)
			{
				cell.textLabel.text = @"Sign Out";
				cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}			
		}
		else
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
	}
	else if (section == TwitterSection)
	{
		if (state.hasTwitterCredentials)
		{
			if (row == LoginInfoRow)
			{
				cell.textLabel.text = [NSString stringWithFormat:@"signed in as @%@", state.twitterUsername];
				cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
				cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
			}
			else if (row == LoginActionRow)
			{
				cell.textLabel.text = @"Sign Out";
				cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}			
		}
		else
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
	}
	
	return cell;
}

@end
