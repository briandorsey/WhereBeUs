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
@synthesize frontSideNavigationController;
@synthesize backSideNavigationController;

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
		
	}
	else
	{
	}
	
	
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
	[navigationController release];
	[window release];
	[super dealloc];
}


//---------------------------------------------------------
// Facebook Session
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

// Called when a user has successfully logged in and begun a session.
- (void)session:(FBSession*)session didLogin:(FBUID)fbuid
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", fbuid], @"uids", @"name, pic_square", @"fields", nil];
	[ConnectionHelper fb_requestWithTarget:self action:@selector(done_facebookUsersGetInfo:) call:@"facebook.users.getInfo" params:params];	
}

// Called when a user closes the login dialog without logging in.
- (void)sessionDidNotLogin:(FBSession*)session
{
	WhereBeUsState *state = [WhereBeUsState shared];
	[state clearFacebookCredentials];
	[state save];
}

// Called when a session is about to log out.
- (void)session:(FBSession*)session willLogout:(FBUID)uid
{
}

// Called when a session has logged out.
- (void)sessionDidLogout:(FBSession*)session
{
	WhereBeUsState *state = [WhereBeUsState shared];
	[state clearFacebookCredentials];
	[state save];	
}

@end

