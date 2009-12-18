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
- (void)discloseAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;
@end

@interface MapViewController : UIViewController<MKMapViewDelegate, WhereBeUsAnnotationManager, UITextFieldDelegate, CLLocationManagerDelegate> {
	// the UI (is simple!)
	IBOutlet MKMapView *mapView;
	IBOutlet UIButton *backSideButton;
	IBOutlet UIButton *chatButton;
	
	// location management
	CLLocationManager *locationManager;
	NSTimer *serviceSyncTimer;
	
	CLLocationAccuracy bestHorizontalAccuracy;
	CLLocationCoordinate2D currentCoordinate;
	BOOL hasCoordinate;

	// neato!
	NSMutableDictionary *displayNameToAnnotation;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIButton *backSideButton;
@property (nonatomic, retain) IBOutlet UIButton *chatButton;

// actions
- (IBAction)backSideButtonPushed:(id)sender;
- (IBAction)chatButtonPushed:(id)sender;

@end
