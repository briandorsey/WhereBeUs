//
//  WhereBeUsAppDelegate.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "WhereBeUsAppDelegate.h"
#import "WhereBeUsState.h"
#import "TwitterCredentialsViewController.h"
#import "MapViewController.h"
#import "TweetViewController.h"
#import "LoginViewController.h"

@implementation WhereBeUsAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)showMapViewController:(BOOL)animated
{
	MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
	[navigationController pushViewController:mapViewController animated:animated];
}

- (void)showModalTweetViewController
{
//	TweetViewController *controller = [[[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil] autorelease];
//	controller.delegate = self;
//	
//	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	[navigationController.topViewController presentModalViewController:controller animated:YES];
}

- (void)showTwitterCredentialsController
{
	TwitterCredentialsViewController *controller = [[TwitterCredentialsViewController alloc] initWithNibName:@"TwitterCredentialsViewController" bundle:nil];	
	controller.delegate = self;
	[navigationController pushViewController:controller animated:YES];
}

- (void)twitterCredentialsViewControllerDidFinish:(TwitterCredentialsViewController *)controller
{
	[navigationController popViewControllerAnimated:YES];
	[controller release];
}

- (void)showLoginViewController:(BOOL)animated
{
	LoginViewController *loginViewController = [[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] autorelease];
	[navigationController pushViewController:loginViewController animated:animated];
}

- (void)popViewController:(BOOL)animated
{
	[navigationController popViewControllerAnimated:YES];	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
	// Set up the facebook session
	NSString *path = [[NSBundle mainBundle] pathForResource:@"FacebookKeysActual" ofType:@"plist"];
	NSDictionary *keys = [[NSDictionary alloc] initWithContentsOfFile:path];	
	NSString *apiKey = (NSString *)[keys objectForKey:@"FacebookApiKey"];
	NSString *apiSecret = (NSString *)[keys objectForKey:@"FacebookApiSecret"];
	facebookSession = [[FBSession sessionForApplication:apiKey secret:apiSecret delegate:self] retain];
	[facebookSession resume]; /* returns YES if user is logged in... */
	
	// Load our application state (potentially from a file)
	WhereBeUsState *state = [WhereBeUsState shared];
	
	if (state.hasTwitterCredentials)
	{
		[self showMapViewController:NO];
	}
	else
	{
		[self showLoginViewController:NO];
	}

//	[navigationController setNavigationBarHidden:YES animated:NO];
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	// XXX TODO 
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	WhereBeUsState *state = [WhereBeUsState shared];
	
	if (state.isDirty)
	{
		[state save];
	}
}

- (void)dealloc 
{
	[facebookSession release];
	[navigationController release];
	[window release];
	[super dealloc];
}


//---------------------------------------------------------
// Facebook Session
//---------------------------------------------------------

- (FBSession *)facebookSession
{
	return facebookSession;
}

// Called when a user has successfully logged in and begun a session.
- (void)session:(FBSession*)session didLogin:(FBUID)uid
{
}

// Called when a user closes the login dialog without logging in.
- (void)sessionDidNotLogin:(FBSession*)session
{
}

// Called when a session is about to log out.
- (void)session:(FBSession*)session willLogout:(FBUID)uid
{
}

// Called when a session has logged out.
- (void)sessionDidLogout:(FBSession*)session
{
}

@end

