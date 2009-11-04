//
//  MapController.h
//  TweetSpot
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"
#import "TweetSpotWindow.h"

@interface MapViewController : UIViewController<MKMapViewDelegate, TweetSpotWindowDelegate, UITextFieldDelegate, CLLocationManagerDelegate> {
	// overlay area
	IBOutlet UIView *overlayView;
	IBOutlet UIButton *previousButton;
	IBOutlet UIButton *nextButton;	
	IBOutlet UILabel *usernameLabel;
	IBOutlet AsyncImageView *userIconView;
	
	// map area
	IBOutlet MKMapView *mapView;
	
	// state
	BOOL updatingLocation;
	BOOL gettingLocationUpdates;
	NSTimer *updateWatchingTimer;	
}

@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet AsyncImageView *userIconView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;


// actions
- (IBAction)tweetButtonPushed:(id)sender;
- (IBAction)hashtagFieldTextChanged:(id)sender;
- (IBAction)previousButtonPushed:(id)sender;
- (IBAction)nextButtonPushed:(id)sender;

@end
