//
//  TweetSpotAppDelegate.m
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "TweetSpotAppDelegate.h"
#import "TweetSpotState.h"
#import "MapViewController.h"

@implementation TweetSpotAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)showMapViewController
{
	MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
	[navigationController pushViewController:mapViewController animated:NO];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{   
	// Load our application state (potentially from a file)
	TweetSpotState *state = [TweetSpotState shared];

	// because of the way MainWindow.xib is set up, our navigation controller
	// already has the twitter credentials view pushed onto it
	
	if (state.hasTwitterCredentials)
	{
		// but we already have valid credentials, so manually
		// inflate the Map xib and push it onto the navigation hierarchy
		[self showMapViewController];
	}

	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
	TweetSpotState *state = [TweetSpotState shared];
	
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


@end

