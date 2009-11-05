//
//  MapController.h
//  TweetSpot
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TweetSpotWindow.h"
#import "TweetSpotAppDelegate.h"

@interface MapViewController : UIViewController<MKMapViewDelegate, TweetSpotWindowDelegate, UITextFieldDelegate, CLLocationManagerDelegate, TweetSpotHashtagChangedDelegate> {
	// overlay area
	IBOutlet UIView *overlayView;
	IBOutlet UIButton *previousButton;
	IBOutlet UIButton *nextButton;	
	IBOutlet UILabel *usernameLabel;
	IBOutlet UIImageView *userIconView;
	
	// map area
	IBOutlet MKMapView *mapView;
	
	// location management
	CLLocationManager *locationManager;
	BOOL updatingLocation;
	BOOL gettingLocationUpdates;
	NSTimer *updateWatchingTimer;
	
	CLLocationAccuracy bestHorizontalAccuracy;
	CLLocationCoordinate2D currentCoordinate;
	BOOL hasCoordinate;
	
	// keep this handy for performance
	NSMutableDictionary *twitterUsernameToAnnotation;
}

@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *userIconView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;


// actions
- (IBAction)tweetButtonPushed:(id)sender;
- (IBAction)hashtagFieldTextChanged:(id)sender;
- (IBAction)previousButtonPushed:(id)sender;
- (IBAction)nextButtonPushed:(id)sender;

- (void)updateServiceWithLocation;

@end
