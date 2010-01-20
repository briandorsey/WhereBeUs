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

const NSTimeInterval SpinnerSeconds = 0.75;

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookCredentialsChanged:) name:FACEBOOK_CREDENTIALS_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterCredentialsChanged:) name:TWITTER_CREDENTIALS_CHANGED object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	facebookActivity = NO;
	twitterActivity = NO;
	
	WhereBeUsState *state = [WhereBeUsState shared];	
	[self.doneButton setEnabled:state.hasAnyCredentials];
	[self.tableView reloadData];	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)doneButtonPressed:(id)sender
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) [UIApplication sharedApplication].delegate;
	[appDelegate flip:YES];
}

- (IBAction)aboutButtonPressed:(id)sender
{
	// CONSIDER -- maybe do something else? Will this be a surprise to users?
	// We shall see...
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wherebe.us/about/iphone/"]];
}

- (void)dealloc 
{
	self.tableView = nil;
	self.doneButton = nil;
	[twitterTimer invalidate];
	[facebookTimer invalidate];
    [super dealloc];
}


//-----------------------------------------------------------------------
// NSTimer Callbacks
//-----------------------------------------------------------------------

- (void)facebookTimerFiredForLogout:(NSTimer *)timer
{
	// clear activity and timer
	facebookActivity = NO;
	[facebookTimer invalidate];
	facebookTimer = nil;	

	// logout will ultimately call our credentialsChanged notification
	FBSession *session = [FBSession session];
	[session logout];
}

- (void)twitterTimerFiredForLogout:(NSTimer *)timer
{
	// clear activity and timer
	twitterActivity = NO;
	[twitterTimer invalidate];
	twitterTimer = nil;	

	// clear the user's twitter credentials. 
	// (this will ultimately call our credentialsChanged notification)
	WhereBeUsState *state = [WhereBeUsState shared];
	[state clearTwitterCredentials];
	[state save];
}


//-----------------------------------------------------------------------
// NSNotification Recipient
//-----------------------------------------------------------------------

- (void)facebookCredentialsChanged:(NSNotification*)notification
{
	facebookActivity = NO;
	WhereBeUsState *state = [WhereBeUsState shared];
	[self.doneButton setEnabled:state.hasAnyCredentials];
	[self.tableView reloadData];
}

- (void)twitterCredentialsChanged:(NSNotification*)notification
{
	twitterActivity = NO;
	WhereBeUsState *state = [WhereBeUsState shared];
	[self.doneButton setEnabled:state.hasAnyCredentials];
	[self.tableView reloadData];	
	
	if (state.hasTwitterCredentials)
	{
		WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) [UIApplication sharedApplication].delegate;
		[appDelegate updateTwitterFriends];
	}
}


//-----------------------------------------------------------------------
// UITableViewDelegate
//-----------------------------------------------------------------------

- (NSIndexPath *)tableView:(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger row = [indexPath indexAtPosition:1];

	if (row == LoginActionRow)
	{
		NSUInteger section = [indexPath indexAtPosition:0];		
		// Only allow selection if we're not actively logging in or out for this item
		if (
			((section == FacebookSection) && !facebookActivity) ||
			((section == TwitterSection) && !twitterActivity))
		{
			return indexPath;
		}
	}
				
	return nil;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	NSUInteger section = [indexPath indexAtPosition:0];
	WhereBeUsState *state = [WhereBeUsState shared];
		
	if (section == FacebookSection)
	{
		facebookActivity = YES;
		
		if (state.hasFacebookCredentials)
		{
			facebookTimer = [NSTimer scheduledTimerWithTimeInterval:SpinnerSeconds target:self selector:@selector(facebookTimerFiredForLogout:) userInfo:nil repeats:NO];
		}
		else
		{
			[self showFacebookCredentials];
		}		
	}
	else if (section == TwitterSection)
	{
		twitterActivity = YES;
		
		if (state.hasTwitterCredentials)
		{
			twitterTimer = [NSTimer scheduledTimerWithTimeInterval:SpinnerSeconds target:self selector:@selector(twitterTimerFiredForLogout:) userInfo:nil repeats:NO];
		}
		else
		{		
			[self showTwitterCredentials];
		}
	}
	
	[self.tableView reloadData];	
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
	// TODO DAVEPECK XXX :: simplify/refactor this logic -- it was simple, many checkins ago. Now it is absurdly repetitive.
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
				cell.textLabel.text = [NSString stringWithFormat:@"signed in as %@", state.facebookDisplayName];
				cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
				cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}		
			else if (row == LoginActionRow)
			{
				if (facebookActivity)
				{
					cell.textLabel.text = @"Signing Out...";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
					cell.accessoryView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
					[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
				}
				else
				{
					cell.textLabel.text = @"Sign Out";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}			
		}
		else
		{
			if (row == LoginInfoRow)
			{
				cell.textLabel.text = @"not signed in";
				cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
				cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}		
			else if (row == LoginActionRow)
			{
				if (facebookActivity)
				{
					cell.textLabel.text = @"Signing In...";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
					cell.accessoryView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
					[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
				}
				else
				{
					cell.textLabel.text = @"Sign In";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
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
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			else if (row == LoginActionRow)
			{
				if (twitterActivity)
				{
					cell.textLabel.text = @"Signing Out...";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
					cell.accessoryView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
					[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
				}
				else
				{
					cell.textLabel.text = @"Sign Out";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}			
		}
		else
		{
			if (row == LoginInfoRow)
			{
				cell.textLabel.text = @"not signed in";
				cell.textLabel.font = [UIFont systemFontOfSize:17.0];			
				cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			else if (row == LoginActionRow)
			{
				if (twitterActivity)
				{
					cell.textLabel.text = @"Signing In...";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
					cell.accessoryView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
					[(UIActivityIndicatorView *)cell.accessoryView startAnimating];
				}
				else
				{
					cell.textLabel.text = @"Sign In";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];			
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
			}
		}
	}
	
	return cell;
}

@end
