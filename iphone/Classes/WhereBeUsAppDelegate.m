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
#import "LoginViewController.h"
#import "ConnectionHelper.h"
#import "JsonResponse.h"
#import "FlurryAPI.h"

@implementation WhereBeUsAppDelegate

//----------------------------------------------------------------
// Private Helpers
//----------------------------------------------------------------



//----------------------------------------------------------------
// Public APIs
//----------------------------------------------------------------

@synthesize window;
@synthesize frontSideNavigationController;
@synthesize backSideNavigationController;

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
	
	if (showingFrontSide)
	{
		[self.frontSideNavigationController dismissModalViewControllerAnimated:animated];
	}
	else
	{
		[self.frontSideNavigationController presentModalViewController:self.backSideNavigationController animated:animated];
	}
}


//----------------------------------------------------------------
// Private Overrides, etc.
//----------------------------------------------------------------

- (void)twitterFollowerUpdateFinished:(JsonResponse *)response
{
	if (response != nil && response.isDictionary)
	{
		WhereBeUsState *state = [WhereBeUsState shared];
		NSDictionary *dictionary = response.dictionary;
		NSArray *ids = [dictionary objectForKey:@"ids"];
		NSString *previousCursor = [dictionary objectForKey:@"previous_cursor_str"];
		NSString *nextCursor = [dictionary objectForKey:@"next_cursor_str"];
		
		if ([@"0" isEqualToString:previousCursor])
		{
			// This was our first request, so clear out our old list entirely...
			[state setTwitterFollowerIds:ids];
		}
		else
		{
			// This was NOT our first request, so append old list with new list
			[state setTwitterFollowerIds:[[state twitterFollowerIds] arrayByAddingObjectsFromArray:ids]];
		}
		
		if (![@"0" isEqualToString:nextCursor])
		{
			// There are more followers to come... so request them...
			[ConnectionHelper twitter_getFollowersWithTarget:self action:@selector(twitterFollowerUpdateFinished:) username:state.twitterUsername password:state.twitterPassword cursor:nextCursor];			
		}
		
		[state save];
	}	
}

- (void)updateTwitterFriends
{
	WhereBeUsState *state = [WhereBeUsState shared];
	[ConnectionHelper twitter_getFollowersWithTarget:self action:@selector(twitterFollowerUpdateFinished:) username:state.twitterUsername password:state.twitterPassword cursor:STARTING_CURSOR];
}

void uncaughtExceptionHandler(NSException *exception) 
{
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
    // Disable auto-lock, since location updates stop when locked.
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
	// Set up the facebook session.
	NSString *path = [[NSBundle mainBundle] pathForResource:@"FacebookKeysActual" ofType:@"plist"];
	NSDictionary *keys = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];	
	NSString *apiKey = (NSString *)[keys objectForKey:@"FacebookApiKey"];
	NSString *apiSecret = (NSString *)[keys objectForKey:@"FacebookApiSecret"];
	facebookSession = [[FBSession sessionForApplication:apiKey secret:apiSecret delegate:self] retain];
	
	// Start up Flurry analytics, if we have a key
	NSString *flurryKey = (NSString *)[keys objectForKey:@"FlurryApiKey"];
	if (![@"missing_key" isEqualToString:flurryKey])
	{
		[FlurryAPI startSession:flurryKey];
		NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);		
	}
	
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
	
	// Deal with re-capturing our twitter friend Id list, if necessary
	if (state.hasTwitterCredentials)
	{
		[self updateTwitterFriends];
	}

	// Get our frontside/backside transitions set up
	frontSideNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	backSideNavigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	
	// Show the frontside opportunistically
	showingFrontSide = YES;
	[window addSubview:self.frontSideNavigationController.view];
	
	// But immediately transition to backside if we need credentials.
	if (!state.hasAnyCredentials)
	{
		[self flip:NO];
	}
	
	[window setBackgroundColor:[UIColor blackColor]]; 
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
	self.frontSideNavigationController = nil;
	self.backSideNavigationController = nil;
	[facebookSession release];
	[super dealloc];
}


//---------------------------------------------------------
// Facebook Session Delegate
//---------------------------------------------------------

- (void)done_facebookPermissionQuery:(id)result
{
	if (result != nil)
	{
		if ([result isEqualToString:@"1"])
		{
			WhereBeUsState *state = [WhereBeUsState shared];
			[state setHasFacebookStatusUpdatePermission:YES];
			[state save];
		}
	}
}

- (void)done_facebookFollowerIdsQuery:(id)result
{
	if ((result != nil) && ([result isKindOfClass:[NSArray class]]))
	{
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:[result count]];
		
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterNoStyle];
		for (id uid_container in result)
		{
			NSString *string_friend_id = [uid_container objectForKey:@"uid"];
			NSNumber *number_friend_id = [formatter numberFromString:string_friend_id];
			[array addObject:number_friend_id];
		}
		[formatter release];		
		
		NSArray *finalArray = [NSArray arrayWithArray:array];
		
		WhereBeUsState *state = [WhereBeUsState shared];
		[state setFacebookFollowerIds:finalArray];
		[state save];		
	}
}

- (void)done_facebookUsersGetInfo:(id)result
{
	WhereBeUsState *state = [WhereBeUsState shared];
	
	if (result != nil)
	{
  		NSDictionary* user = [result objectAtIndex:0];
		[state setFacebookUserId:(FBUID)[FBSession session].uid 
					 displayName:[user objectForKey:@"name"] 
				 profileImageURL:[user objectForKey:@"pic_square"]
			largeProfileImageURL:[user objectForKey:@"pic"]
					  serviceURL:[user objectForKey:@"profile_url"]];
		
		// Query to see if they've given us status_update permissions in the past
		NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", state.facebookUserId], @"uid", @"status_update", @"ext_perm", nil];
		[ConnectionHelper fb_requestWithTarget:self action:@selector(done_facebookPermissionQuery:) call:@"facebook.users.hasAppPermission" params:params];
		
		// Also, query for the IDs of my friends...
		params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", state.facebookUserId], @"uid", nil];
		[ConnectionHelper fb_requestWithTarget:self action:@selector(done_facebookFollowerIdsQuery:) call:@"facebook.friends.get" params:params];
	}
	else
	{
		[state clearFacebookCredentials];
	}
	
	[state save];	
}

- (void)session:(FBSession*)session didLogin:(FBUID)fbuid
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", fbuid], @"uids", @"name, pic_square, pic, profile_url", @"fields", nil];
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

