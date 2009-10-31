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

@interface MapViewController : UIViewController<MKMapViewDelegate, TweetSpotWindowDelegate> {
	// top area
	IBOutlet UIBarButtonItem *broadcastButton;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	
	// overlay area
	IBOutlet UIView *overlayView;
	IBOutlet UIButton *previousButton;
	IBOutlet UIButton *nextButton;	
	IBOutlet UILabel *usernameLabel;
	IBOutlet AsyncImageView *userIconView;
	
	// map area
	IBOutlet MKMapView *mapView;
}	

@property (nonatomic, retain) IBOutlet UIBarButtonItem *broadcastButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet AsyncImageView *userIconView;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;


// actions
- (IBAction)broadcastButtonPushed:(id)sender;
- (IBAction)tweetButtonPushed:(id)sender;
- (IBAction)hashFieldTextChanged:(id)sender;
- (IBAction)previousButtonPushed:(id)sender;
- (IBAction)nextButtonPushed:(id)sender;

@end
