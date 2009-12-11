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
#import "ConnectionHelper.h"


@implementation WhereBeUsAppDelegate

@synthesize window;


//----------------------------------------------------------------
// Private Helpers
//----------------------------------------------------------------

- (void)showCurrentView
{
	if (showingFrontSide)
	{
		if (backSideNavigationController != nil)
		{
			[[backSideNavigationController view] removeFromSuperview];
		}
		
		[window addSubview:[self frontSideNavigationController].view];
	}
	else
	{
		if (frontSideNavigationController != nil)
		{
			[[frontSideNavigationController view] removeFromSuperview];
		}
		
		[window addSubview:[self backSideNavigationController].view];
	}	
}


//----------------------------------------------------------------
// Public APIs
//----------------------------------------------------------------

- (FrontSideNavigationController *)frontSideNavigationController
{
	if (frontSideNavigationController == nil)
	{
		frontSideNavigationController = [[FrontSideNavigationController alloc] initWithNibName:@"FrontSideNavigationController" bundle:nil];
	}
	
	return frontSideNavigationController;
}

- (BackSideNavigationController *)backSideNavigationController
{
	if (backSideNavigationController == nil)
	{
		backSideNavigationController = [[BackSideNavigationController alloc] initWithNibName:@"BackSideNavigationController" bundle:nil];
	}
	
	return backSideNavigationController;
}

- (BOOL)showingFrontSide
{
	return showingFrontSide;
}

- (BOOL)showingBackSide
{
	return !showingFrontSide;
}

- (void)flip:(BOOL)animated
{
	showingFrontSide = !showingFrontSide;
	[self showCurrentView];
}


//----------------------------------------------------------------
// Private Overrides, etc.
//----------------------------------------------------------------

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
	// Set up the facebook session.
	NSString *path = [[NSBundle mainBundle] pathForResource:@"FacebookKeysActual" ofType:@"plist"];
	NSDictionary *keys = [[NSDictionary alloc] initWithContentsOfFile:path];	
	NSString *apiKey = (NSString *)[keys objectForKey:@"FacebookApiKey"];
	NSString *apiSecret = (NSString *)[keys objectForKey:@"FacebookApiSecret"];
	FBSession *facebookSession = [[FBSession sessionForApplication:apiKey secret:apiSecret delegate:self] retain];
	
	// Load our application state (potentially from a file)
	WhereBeUsState *state = [WhereBeUsState shared];

	// Did we have a facebook session before? If so, attempt to resume it.
	if (state.hasFacebookCredentials)
	{
		BOOL success = [facebookSession resume];
		// If we were successful, the facebook session calls the "logged in" 
		// delegate method. So we have nothing to do.
		// On the other hand, if resume is NOT successful, no delegate
		// methods are called and we have to clear out credentials by hand.
		if (!success)
		{
			[state clearFacebookCredentials];
		}
	}
	
	// Do we have _any_ credentials (twitter or facebook)?
	// If so, show the 'front side' of the app. Otherwise,
	// immediately show the 'back side' login/settings views.
	if (state.hasAnyCredentials)
	{
		showingFrontSide = YES;
	}
	else
	{
		showingFrontSide = NO;
	}
	[self showCurrentView];

    [window makeKeyAndVisible];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	// XXX TODO DAVEPECK
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
	self.window = nil;
	[frontSideNavigationController release];
	[backSideNavigationController release];
	[super dealloc];
}


//---------------------------------------------------------
// Facebook Session Delegate
//---------------------------------------------------------

- (void)done_facebookUsersGetInfo:(id)result
{
	WhereBeUsState *state = [WhereBeUsState shared];
	
	if (result != nil)
	{
  		NSDictionary* user = [result objectAtIndex:0];
		[state setFacebookUserId:(FBUID)[FBSession session].uid fullName:[user objectForKey:@"name"] profileImageURL:[user objectForKey:@"pic_square"]];
	}
	else
	{
		[state clearFacebookCredentials];
	}
	
	[state save];	
}

- (void)session:(FBSession*)session didLogin:(FBUID)fbuid
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", fbuid], @"uids", @"name, pic_square", @"fields", nil];
	[ConnectionHelper fb_requestWithTarget:self action:@selector(done_facebookUsersGetInfo:) call:@"facebook.users.getInfo" params:params];	
}

- (void)sessionDidNotLogin:(FBSession*)session
{
	WhereBeUsState *state = [WhereBeUsState shared];
	[state clearFacebookCredentials];
	[state save];
}

- (void)session:(FBSession*)session willLogout:(FBUID)uid
{
}

- (void)sessionDidLogout:(FBSession*)session
{
	WhereBeUsState *state = [WhereBeUsState shared];
	[state clearFacebookCredentials];
	[state save];	
}

@end

