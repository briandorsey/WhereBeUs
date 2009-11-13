//
//  TweetSpotAppDelegate.m
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "TweetSpotAppDelegate.h"
#import "TweetSpotState.h"
#import "TwitterCredentialsViewController.h"
#import "MapViewController.h"
#import "TweetViewController.h"

@implementation TweetSpotAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)showMapViewController:(BOOL)animated
{
	MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
	[navigationController pushViewController:mapViewController animated:animated];
}

- (void)showTweetViewController:(BOOL)animated
{
	TweetViewController *tweetViewController = [[[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil] autorelease];
	[navigationController pushViewController:tweetViewController animated:animated];	
}

- (void)popViewController:(BOOL)animated
{
	[navigationController popViewControllerAnimated:YES];	
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
	hashtagDelegate = nil;
	
	// Load our application state (potentially from a file)
	/* ignore return value */ [TweetSpotState shared];

	[self showMapViewController:NO];
	[navigationController setNavigationBarHidden:YES animated:NO];
	

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	// XXX TODO check validity of URL	
	// tweetthespotone://hashtag/
	
	if (hashtagDelegate != nil)
	{
		[hashtagDelegate gotNewHashtag:[url host]];
	}
	else
	{
		TweetSpotState *state = [TweetSpotState shared];
		state.currentHashtag = [url host];	
	}
	
	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	TweetSpotState *state = [TweetSpotState shared];
	
	if (state.isDirty)
	{
		[state save];
	}
}

- (void)setHashtagDelegate:(id<TweetSpotHashtagChangedDelegate>)newHashtagDelegate
{
	hashtagDelegate = newHashtagDelegate;
}

- (void)dealloc 
{
	hashtagDelegate = nil;
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

