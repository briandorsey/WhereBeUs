//
//  MapController.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WhereBeUsWindow.h"
#import "WhereBeUsAppDelegate.h"

@protocol WhereBeUsAnnotationManager
- (void)forceAnnotationsToUpdate;
- (CGRect)getScreenBoundsForRect:(CGRect)rect fromView:(UIView *)view;
- (void)moveMapByDeltaX:(CGFloat)deltaX deltaY:(CGFloat)deltaY forView:(UIView *)view;
- (void)deselectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate, WhereBeUsAnnotationManager, WhereBeUsWindowDelegate, UITextFieldDelegate, CLLocationManagerDelegate, WhereBeUsHashtagChangedDelegate> {
	// hashtag
	IBOutlet UITextField *hashtagField;
	IBOutlet UIButton *tweetButton;
	
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

@property (nonatomic, retain) IBOutlet UITextField *hashtagField;
@property (nonatomic, retain) IBOutlet UIButton *tweetButton;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

// actions
- (IBAction)tweetButtonPushed:(id)sender;
- (IBAction)hashtagFieldTextChanged:(id)sender;

- (void)updateServiceWithLocation;

@end
