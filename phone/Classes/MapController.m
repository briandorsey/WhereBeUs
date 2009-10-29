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

@synthesize navigationBar;
@synthesize broadcastButton;
@synthesize hashField;
@synthesize activityIndicator;
@synthesize overlayView;
@synthesize previousButton;
@synthesize nextButton;
@synthesize usernameLabel;
@synthesize userIconView;
@synthesize mapView;


//------------------------------------------------------------------
// Private implementation
//------------------------------------------------------------------

- (void)hideOverlay
{	
	CGRect rect = self.view.frame;	
	overlayView.frame = CGRectMake(rect.origin.x, rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
	overlayView.hidden = YES;
}

- (void)dealloc
{
	self.navigationBar = nil;
	self.broadcastButton = nil;
	self.hashField = nil;
	self.activityIndicator = nil;
	self.overlayView = nil;
	self.previousButton = nil;
	self.nextButton = nil;
	self.usernameLabel = nil;
	self.userIconView = nil;
	self.mapView = nil;
	
    [super dealloc];
}


//------------------------------------------------------------------
// Actions
//------------------------------------------------------------------

- (IBAction)broadcastButtonPushed:(id)sender
{
}

- (IBAction)tweetButtonPushed:(id)sender
{
}

- (IBAction)hashFieldTextChanged:(id)sender
{
}

- (IBAction)previousButtonPushed:(id)sender
{
}

- (IBAction)nextButtonPushed:(id)sender
{
}


//------------------------------------------------------------------
// Map View Delegate
//------------------------------------------------------------------



//------------------------------------------------------------------
// Tweet Spot Window Delegate
//------------------------------------------------------------------

- (void)gotWindowEvent:(UIEvent *)event
{
	// if the user clicks away from the text field, blur it
	if ([self.hashField isFirstResponder])
	{
		if ([event type] == UIEventTypeTouches)
		{
			NSSet *set = [event allTouches];
			for (UITouch *touch in set)
			{
				CGPoint location = [touch locationInView:self.view];
				if (location.y >= self.navigationBar.frame.size.height)
				{
					[self.hashField resignFirstResponder];
					break;
				}
			}
		}
	}
}


//------------------------------------------------------------------
// UIViewController overrides
//------------------------------------------------------------------

- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self hideOverlay];
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
	[delegate.window setWindowDelegate:self];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	TweetSpotAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate.window setWindowDelegate:nil];	
    [super viewWillDisappear:animated];
}


@end
