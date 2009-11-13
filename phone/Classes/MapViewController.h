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

@interface MapViewController : UIViewController<MKMapViewDelegate, WhereBeUsAnnotationManager, UITextFieldDelegate, CLLocationManagerDelegate> {
	// the UI (is simple!)
	IBOutlet MKMapView *mapView;
	IBOutlet UIButton *tweetButton;
	
	// location management
	CLLocationManager *locationManager;
	BOOL updatingLocation;
	BOOL gettingLocationUpdates;
	NSTimer *updateWatchingTimer;
	
	CLLocationAccuracy bestHorizontalAccuracy;
	CLLocationCoordinate2D currentCoordinate;
	BOOL hasCoordinate;

	// neato!
	NSMutableDictionary *twitterUsernameToAnnotation;
}

@property (nonatomic, retain) IBOutlet UIButton *tweetButton;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

// actions
- (IBAction)tweetButtonPushed:(id)sender;

- (void)updateServiceWithLocation;

@end
