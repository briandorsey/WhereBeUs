//
//  MapController.m
//  TweetSpot
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "MapViewController.h"
#import "TweetSpotAppDelegate.h"
#import "TweetSpotState.h"
#import "Utilities.h"
#import "ConnectionHelper.h"
#import "JsonResponse.h"

static const NSTimeInterval kUpdateTimerSeconds = 15;

@implementation MapViewController


//------------------------------------------------------------------
// Properties
//------------------------------------------------------------------

@synthesize overlayView;
@synthesize previousButton;
@synthesize nextButton;
@synthesize usernameLabel;
@synthesize userIconView;
@synthesize mapView;


//------------------------------------------------------------------
// Update Watching/Timer
//------------------------------------------------------------------

- (void)ts_finishedGetUpdatesForHashtag:(JsonResponse *)response
{
	if (response != nil)
	{
		NSDictionary *dictionary = [response dictionary];
		[Utilities displayModalAlertWithTitle:@"Got updates" message:[dictionary objectForKey:@"message"] buttonTitle:@"FINE"];
	}
	gettingLocationUpdates = NO;
	// XXX TODO
}

- (void)updateTimerFired:(NSTimer *)timer
{
	if (!gettingLocationUpdates)
	{
		gettingLocationUpdates = YES;
		[ConnectionHelper ts_getUpdatesForHashtagWithTarget:self action:@selector(ts_finishedGetUpdatesForHashtag:) hashtag:[TweetSpotState shared].currentHashtag];
	}
}

- (void)startWatchingForUpdates
{
	// if we're already watching, we probably want to force a 'watch' right now
	if (updateWatchingTimer != nil)
	{
		[updateWatchingTimer fire];
		return;
	}
	
	updateWatchingTimer = [[NSTimer scheduledTimerWithTimeInterval:kUpdateTimerSeconds target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES] retain];
}

- (void)stopWatchingForUpdates
{
	if (updateWatchingTimer != nil)
	{
		[updateWatchingTimer invalidate];
		[updateWatchingTimer release];
		updateWatchingTimer = nil;
	}
}


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
	self.overlayView = nil;
	self.previousButton = nil;
	self.nextButton = nil;
	self.usernameLabel = nil;
	self.userIconView = nil;
	self.mapView = nil;
	
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[self stopWatchingForUpdates];
	
    [super dealloc];
}


//------------------------------------------------------------------
// Actions
//------------------------------------------------------------------

- (IBAction)tweetButtonPushed:(id)sender
{
}

- (IBAction)hashtagFieldTextChanged:(id)sender
{
	/* for now this is a no-op -- we only start a new search when you blur the hashtag text field */
}

- (IBAction)previousButtonPushed:(id)sender
{
}

- (IBAction)nextButtonPushed:(id)sender
{
}

//------------------------------------------------------------------
// Hash Tag Field Management (UITextField delegate, etc.)
//------------------------------------------------------------------

- (UITextField *)hashtagField
{
	return (UITextField *) self.navigationItem.titleView;
}

- (void)updateCurrentHashtag
{
	TweetSpotState *state = [TweetSpotState shared];
	
	if (![self.hashtagField.text isEqualToString:state.currentHashtag])
	{
		state.currentHashtag = self.hashtagField.text;
		[state save];
		
		if ([state.currentHashtag length] > 0)
		{
			[self startWatchingForUpdates];
		}
		else
		{
			[self stopWatchingForUpdates];
		}
	}
	
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSAssert(textField == self.hashtagField, @"Unexpected delegate call.");

	// NSPredicate is a very strange beast, but it turns out it's the way to do regular expressions in Cocoa (among other things)
	NSPredicate *alphanumericOrUnderscore = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[a-zA-Z0-9_]*"];
	return [alphanumericOrUnderscore evaluateWithObject:string];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSAssert(textField == self.hashtagField, @"Unexpected delegate call.");
	[textField resignFirstResponder];
	[self updateCurrentHashtag];
	return YES;
}


//------------------------------------------------------------------
// Location Manager Delegate
//------------------------------------------------------------------

- (void)ts_finishedPostUpdate:(id)result
{
	updatingLocation = NO;
	// XXX TODO -- think we want to use a timer for post/get
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (!updatingLocation)
	{
		TweetSpotState *state = [TweetSpotState shared];
		if (state.currentHashtag != nil && [state.currentHashtag length] > 0)
		{
			updatingLocation = YES;
			[ConnectionHelper ts_postUpdateWithTarget:self action:@selector(ts_finishedPostUpdate:) twitterUsername:state.twitterUsername twitterFullName:state.twitterFullName twitterProfileImageURL:state.twitterProfileImageURL hashtag:state.currentHashtag coordinate:newLocation.coordinate];		
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// XXX TODO
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
	if ([self.hashtagField isFirstResponder])
	{
		if ([event type] == UIEventTypeTouches)
		{
			NSSet *set = [event allTouches];
			for (UITouch *touch in set)
			{
				CGPoint location = [touch locationInView:self.view];
				if (location.y >= 42)
				{
					[self.hashtagField resignFirstResponder];
					[self updateCurrentHashtag];
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
		
		// wire up the hash view
		UITextField *hashtagView = [[UITextField alloc] initWithFrame:CGRectMake(0, navigationFrame.origin.y + 5, 150.0, navigationFrame.size.height - 8)];
		hashtagView.borderStyle = UITextBorderStyleBezel;
		hashtagView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
		hashtagView.placeholder = @"hash tag";
		hashtagView.autocorrectionType = UITextAutocorrectionTypeNo; /* it was bugging me -- not sure? */
		hashtagView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		hashtagView.returnKeyType = UIReturnKeyDone;
		hashtagView.text = [TweetSpotState shared].currentHashtag;
		if ([[TweetSpotState shared].currentHashtag length] > 0)
		{
			[self startWatchingForUpdates];
		}
			
		hashtagView.delegate = self;		
		self.navigationItem.titleView = hashtagView;		
		[(UIControl *)self.navigationItem.titleView addTarget:self action:@selector(hashtagFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
		
		// wire up the twitter button
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"tweet" style:UIBarButtonItemStylePlain target:self action:@selector(tweetButtonPushed:)];
		
		// build our location manager
		locationManager = [[CLLocationManager alloc] init];
		locationManager.distanceFilter = 100; /* don't update unless you've moved 100 meters or more */
		locationManager.desiredAccuracy = kCLLocationAccuracyBest; /* i think we definitely want this for our purposes, despite battery drain */
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
		
		// set up state
		updatingLocation = NO;
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
