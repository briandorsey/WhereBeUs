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

- (void)viewWillAppear:(BOOL)animated
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
	FBSession *session = appDelegate.facebookSession;
	[session.delegates addObject:self];
	[self.tableView reloadData];	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
	[appDelegate.facebookSession.delegates removeObject:self];
	[super viewWillDisappear:animated];
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
// FBSessionDelegate
//-----------------------------------------------------------------------

- (void)done_facebookUsername:(id)result
{
	if (result != nil)
	{
		NSArray* users = result;
  		NSDictionary* user = [users objectAtIndex:0];
  		NSString* name = [user objectForKey:@"name"];
		NSLog(@"Name is %@", name);
  		NSString* pc = [user objectForKey:@"pic_square"];
		NSLog(@"Pic Square is %@", pc);
	}
}

- (void)session:(FBSession *)session didLogin:(FBUID)fbuid
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", fbuid], @"uids", @"name, pic_square", @"fields", nil];
	[ConnectionHelper fb_requestWithTarget:self action:@selector(done_facebookUsername:) call:@"facebook.users.getInfo" params:params];
}

- (void)sessionDidLogout:(FBSession*)session
{
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
	
	if (section == FacebookSection)
	{
		WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
		FBSession *session = [appDelegate facebookSession];
		if (session.isConnected)
		{
			[session logout];
		}
		else
		{
			[self showFacebookCredentials];
		}
	}
	else if (section == TwitterSection)
	{
		WhereBeUsState *state = [WhereBeUsState shared];
		if (state.hasTwitterCredentials)
		{
			state.twitterUserId = (TwitterId) 0;
			state.twitterUsername = nil;
			state.twitterPassword = nil;
			state.twitterFullName = nil;
			state.twitterProfileImageURL = nil;
			[state save];
			[self.tableView reloadData];
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

	if (section == FacebookSection)
	{
		WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) ([UIApplication sharedApplication].delegate);
		FBSession *session = [appDelegate facebookSession];
		if (session.isConnected)
		{
			if (row == LoginInfoRow)
			{
				cell.textLabel.text = @"signed in as XXX TODO";
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
		WhereBeUsState *state = [WhereBeUsState shared];
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
