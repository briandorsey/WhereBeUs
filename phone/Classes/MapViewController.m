//
//  MapController.m
//  TweetSpot
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "MapViewController.h"
#import "TweetSpotAppDelegate.h"

@implementation MapViewController


//------------------------------------------------------------------
// Properties
//------------------------------------------------------------------

@synthesize broadcastButton;
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
	self.broadcastButton = nil;
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
	// if the text field has focus and the user clicks outside of it, drop the focus
	if ([self.navigationItem.titleView isFirstResponder])
	{
		if ([event type] == UIEventTypeTouches)
		{
			NSSet *set = [event allTouches];
			for (UITouch *touch in set)
			{
				CGPoint location = [touch locationInView:self.view];
				if (location.y >= 42)
				{
					[self.navigationItem.titleView resignFirstResponder];
					break;
				}
			}
		}
	}
}


//------------------------------------------------------------------
// UIViewController overrides
//------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self != nil) 
	{
		TweetSpotAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		UINavigationController *navigationController = appDelegate.navigationController;
		CGRect navigationFrame = navigationController.navigationBar.frame;
		UITextField *hashView = [[UITextField alloc] initWithFrame:CGRectMake(0, navigationFrame.origin.y + 5, 150.0, navigationFrame.size.height - 8)];
		hashView.borderStyle = UITextBorderStyleBezel;
		hashView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
		hashView.placeholder = @"hash tag";
		self.navigationItem.titleView = hashView;
    }
    return self;
}

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
