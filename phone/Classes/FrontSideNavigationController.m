//
//  FrontSideNavigationController.m
//  WhereBeUs
//
//  Created by Dave Peck on 12/8/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "FrontSideNavigationController.h"

@implementation FrontSideNavigationController

- (void)showMapViewController:(BOOL)animated
{
//	MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil] autorelease];
//	[self pushViewController:mapViewController animated:animated];
}

- (void)showModalTweetViewController
{
	//	TweetViewController *controller = [[[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil] autorelease];
	//	controller.delegate = self;
	//	
	//	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	//	[navigationController.topViewController presentModalViewController:controller animated:YES];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	[self showMapViewController:NO];
}

- (void)dealloc 
{
    [super dealloc];
}


@end
