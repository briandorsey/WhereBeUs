//
//  wherebeusAppDelegate.m
//  wherebeus
//
//  Created by Dave Peck on 11/12/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "wherebeusAppDelegate.h"
#import "MainViewController.h"

@implementation wherebeusAppDelegate


@synthesize window;
@synthesize mainViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
