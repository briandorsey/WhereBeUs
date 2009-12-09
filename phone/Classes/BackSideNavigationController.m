//
//  SettingsNavigationController.m
//  WhereBeUs
//
//  Created by Dave Peck on 12/8/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "BackSideNavigationController.h"


@implementation BackSideNavigationController


//--------------------------------------------------------
// TwitterCredentialsViewControllerDelegate
//--------------------------------------------------------

- (void)twitterCredentialsViewControllerDidFinish:(TwitterCredentialsViewController *)controller
{
	[navigationController popViewControllerAnimated:YES];
	[controller release];
}


//--------------------------------------------------------
// Private Implementation
//--------------------------------------------------------

- (void)showLoginViewController:(BOOL)animated
{
	LoginViewController *loginViewController = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
	[navigationController pushViewController:loginViewController animated:animated];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self showLoginViewController:NO];
}

- (void)dealloc 
{
    [super dealloc];
}


//--------------------------------------------------------
// Public API
//--------------------------------------------------------

- (void)showTwitterCredentialsController
{
	TwitterCredentialsViewController *controller = [[TwitterCredentialsViewController alloc] initWithNibName:@"TwitterCredentialsViewController" bundle:nil];	
	controller.delegate = self;
	[navigationController pushViewController:controller animated:YES];
}


@end
