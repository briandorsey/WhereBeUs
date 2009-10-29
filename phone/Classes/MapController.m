//
//  MapController.m
//  TweetSpot
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "MapController.h"
#import "TweetSpotAppDelegate.h"

@implementation MapController


//------------------------------------------------------------------
// Properties
//------------------------------------------------------------------

@synthesize broadcastButton;
@synthesize hashField;
@synthesize overlayView;
@synthesize previousButton;
@synthesize nextButton;
@synthesize usernameLabel;
@synthesize userIconField;
@synthesize mapView;


//------------------------------------------------------------------
// UIViewController overrides
//------------------------------------------------------------------

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated 
{
	TweetSpotAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.navigationController setNavigationBarHidden:YES animated:animated];	
    [super viewWillAppear:animated];
}


- (void)dealloc
{
	
    [super dealloc];
}


@end
