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

@interface MapController : UIViewController {
	// top area
	IBOutlet UIBarButtonItem *broadcastButton;
	IBOutlet UITextField *hashField;
	
	// overlay area
	IBOutlet UIView *overlayView;
	IBOutlet UIButton *previousButton;
	IBOutlet UIButton *nextButton;	
	IBOutlet UILabel *usernameLabel;
	IBOutlet AsyncImageView *userIconField;
	
	// map area
	IBOutlet MKMapView *mapView;
}	

@property (nonatomic, retain) IBOutlet UIBarButtonItem *broadcastButton;
@property (nonatomic, retain) IBOutlet UITextField *hashField;
@property (nonatomic, retain) IBOutlet UIView *overlayView;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet AsyncImageView *userIconField;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;


// actions

- (void)broadcastButtonPushed:(id)sender;
- (void)tweetButtonPushed:(id)sender;
- (void)hashFieldTextChanged:(id)sender;
- (void)previousButtonPushed:(id)sender;
- (void)nextButtonPushed:(id)sender;

@end
