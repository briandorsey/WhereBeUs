//
//  MapController.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/28/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "MapViewController.h"
#import "WhereBeUsAppDelegate.h"
#import "WhereBeUsState.h"
#import "Utilities.h"
#import "ConnectionHelper.h"
#import "JsonResponse.h"
#import "UpdateAnnotation.h"
#import "UpdateAnnotationView.h"
#import "UserKey.h"

static const NSTimeInterval kServiceSyncSeconds = 15;
#define kDefaultLatLonSpan 0.05

@implementation MapViewController


//------------------------------------------------------------------
// Properties
//------------------------------------------------------------------

@synthesize mapView;
@synthesize backSideButton;
@synthesize chatButton;


//------------------------------------------------------------------
// Code To Sync With Server & Manage Annotations
//------------------------------------------------------------------

- (void)restartServiceSyncTimer
{
	[serviceSyncTimer invalidate];
	[serviceSyncTimer release];
	serviceSyncTimer = [[NSTimer scheduledTimerWithTimeInterval:kServiceSyncSeconds target:self selector:@selector(serviceSyncTimerFired:) userInfo:nil repeats:NO] retain];			
}

- (void)gotSyncResponseFromWhereBeUsServer:(JsonResponse *)response
{
	if (serviceSyncTimer == nil)
	{
		// protect against getting a response back from our 
		// server _after_ we've decided to stop talking to it.
		return;
	}
	
	if (response == nil) 
	{ 
		[self restartServiceSyncTimer];
		return; 
	}
	

	NSDictionary *dictionary = [response dictionary];
	BOOL success = [(NSNumber *)[dictionary objectForKey:@"success"] boolValue];
	if (!success) 
	{ 
		[self restartServiceSyncTimer];
		return; 
	}
	
	// Inside this loop, we walk through all the updates returned by
	// the service. If the update corresponds to an annotation that is
	// not on the map, we add it. If the update corresponds to an annotation
	// that _is_ on the map, we update said annotation. Finally, after
	// looking at all the updates we got back from the service, we check to see
	// if we have any annotations left on the map that were _not_ part of the
	// service update list. If so, we remove those annotations.
	//
	// The final trick to all this is that the iPhone user's own annotation is
	// managed separately, so that it can update itself much more often. That said,
	// the service will return the iPhone user's update information too. We want to 
	// ignore that here.
	NSArray *updates = [dictionary objectForKey:@"updates"];
	WhereBeUsState *state = [WhereBeUsState shared];
	NSString *preferredUserKey = state.preferredUserKey;
				
	// STEP 1: mark all current annotations on the map as NOT VISITED
	for (id key in userKeyToAnnotation)
	{
		UpdateAnnotation *annotation = (UpdateAnnotation *)[userKeyToAnnotation objectForKey:key];
		annotation.visited = NO;
	}
	
	// STEP 2: walk through all update records returned by the service and create, 
	// or update, the corresponding map annotation
	for (NSDictionary *update in updates)
	{				
		NSString *updateUserKey = [UserKey userKeyForUpdate:update];
		
		if (![preferredUserKey isEqualToString:updateUserKey])
		{					
			UpdateAnnotation *annotation = (UpdateAnnotation *)[userKeyToAnnotation objectForKey:updateUserKey];
			
			if (annotation == nil)
			{
				// an annotation for this username doesn't yet exist. Create it.
				annotation = [UpdateAnnotation updateAnnotationWithDictionary:update];
				annotation.visited = YES;
				[userKeyToAnnotation setObject:annotation forKey:updateUserKey];
				[self.mapView addAnnotation:annotation];
			}
			else
			{
				// an annotation already exists. Just update it.
				[annotation updateWithDictionary:update];
				annotation.visited = YES;
			}
		}
	}
	
	// STEP 3: see if there are any annotations on the map that should go away
	NSMutableArray *userKeysThatWentAway = [NSMutableArray arrayWithCapacity:1];
	
	for (id key in userKeyToAnnotation)
	{
		UpdateAnnotation *annotation = (UpdateAnnotation *)[userKeyToAnnotation objectForKey:key];
		NSString *userKey = [annotation userKey];
		
		if (![preferredUserKey isEqualToString:userKey] && !annotation.visited)
		{
			[self.mapView removeAnnotation:annotation];
			[userKeysThatWentAway addObject:userKey];
		}
	}
	
	// (can't remove stuff from twitterUserNameToAnnotation while enumerating it!)
	for (id key in userKeysThatWentAway)
	{
		[userKeyToAnnotation removeObjectForKey:key];
	}

	// Done updating! Make sure the map reflects our changes!
	[self forceAnnotationsToUpdate];		
	[self restartServiceSyncTimer];
}

- (void)serviceSyncTimerFired:(NSTimer *)timer
{
	WhereBeUsState *state = [WhereBeUsState shared];
	
	if (state.hasAnyCredentials)
	{
		// hold on to serviceSyncTimer for a little longer...
		[ConnectionHelper wbu_updateWithTarget:self action:@selector(gotSyncResponseFromWhereBeUsServer:) coordinate:currentCoordinate];
	}
	else
	{
		// we sanity checked and found we had no credentials. So... that's not ideal.
		[self restartServiceSyncTimer];
	}
}

- (void)startSyncingWithService
{
	if (hasCoordinate && serviceSyncTimer == nil)
	{
		// start right away!
		serviceSyncTimer = [[NSTimer scheduledTimerWithTimeInterval:kServiceSyncSeconds target:self selector:@selector(serviceSyncTimerFired:) userInfo:nil repeats:NO] retain];			
		[serviceSyncTimer fire];		
	}
}

- (void)stopSyncingWithService
{
	if (serviceSyncTimer != nil)
	{
		[serviceSyncTimer invalidate];
		[serviceSyncTimer release];
		serviceSyncTimer = nil;
	}
}


//------------------------------------------------------------------
// Actions
//------------------------------------------------------------------

- (IBAction)backSideButtonPushed:(id)sender
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate flip:YES];
}

- (IBAction)chatButtonPushed:(id)sender
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate frontSideNavigationController] showModalSendMessage];
}


//------------------------------------------------------------------
// Map View Management
//------------------------------------------------------------------

- (void)centerAndZoomOnCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated
{
	// Region and Zoom
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	
	span.latitudeDelta = kDefaultLatLonSpan;
	span.longitudeDelta = kDefaultLatLonSpan;
	
	region.span = span;
	region.center = coordinate;
	
	[mapView setRegion:	[mapView regionThatFits:region]	animated:animated];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	// sanity check input
	if (annotation == nil)
	{
		return nil;
	}
	
	// we don't provide custom views for anything but UpdateAnnotations...
	if (![annotation isKindOfClass:[UpdateAnnotation class]])
	{
		return nil;
	}

	// Create, or reuse, an update annotation view
	UpdateAnnotationView *annotationView = (UpdateAnnotationView *) [theMapView dequeueReusableAnnotationViewWithIdentifier:@"UpdateAnnotation"];
	if (annotationView == nil)
	{
		annotationView = [[[UpdateAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"UpdateAnnotation" annotationManager:self] autorelease];
	}
	else
	{
		annotationView.annotation = annotation;
	}
	
	return annotationView;
}


//------------------------------------------------------------------
// WhereBeUsAnnotationManager Delegate
// (for annotation => map view communication)
//------------------------------------------------------------------

- (void)forceAnnotationsToUpdate
{
	// This _actually_ works, which is all the more shocking because
	// if you send animated:YES, it doesn't do anything at all!
	[mapView setCenterCoordinate:mapView.region.center animated:NO];
}

- (CGRect)getScreenBoundsForRect:(CGRect)rect fromView:(UIView *)view
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) [[UIApplication sharedApplication] delegate];
	UIWindow *window = (UIWindow *)appDelegate.window;
	return [window convertRect:rect fromView:view];
}

CGFloat fsign(CGFloat f)
{
	if (f < 0.0)
	{
		return -1.0;
	}
	else if (f > 0.0)
	{
		return 1.0;
	}
	
	return 0.0;
}

- (void)moveMapByDeltaX:(CGFloat)deltaX deltaY:(CGFloat)deltaY forView:(UIView *)view
{
	// how much do we want to move, _in the coordinate system of the requesting view_?
	// (the rectangle's origin isn't so interesting; the _size_ is key)
	CGRect deltaRect = CGRectMake(view.center.x, view.center.y, fabs(deltaX), fabs(deltaY));
	
	// how much motion does this imply in latitude/longitude space?
	MKCoordinateRegion deltaRegion = [mapView convertRect:deltaRect toRegionFromView:view];
	
	// where are we moving to?
	CLLocationCoordinate2D destination;
	destination.latitude = mapView.region.center.latitude + (fsign(deltaY) * deltaRegion.span.latitudeDelta);
	destination.longitude = mapView.region.center.longitude + (fsign(deltaX) * deltaRegion.span.longitudeDelta);
	
	// move!
	[mapView setCenterCoordinate:destination animated:YES];
}

- (void)deselectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated
{
	[mapView deselectAnnotation:annotation animated:animated];
}

- (void)discloseAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated
{
	// currently no-op
}

- (void)showDetailViewForAnnotation:(UpdateAnnotation *)annotation animated:(BOOL)animated
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate frontSideNavigationController] showUpdateDetailView:annotation animated:animated];
}

- (void)clearAllAnnotations
{
	for (id key in userKeyToAnnotation)
	{
		UpdateAnnotation *annotation = (UpdateAnnotation *)[userKeyToAnnotation objectForKey:key];
		[self.mapView removeAnnotation:annotation];
	}
	
	[userKeyToAnnotation removeAllObjects];
}


//------------------------------------------------------------------
// Location Management for the current user, including annotations
//------------------------------------------------------------------

- (void)updateUserAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
	WhereBeUsState *state = [WhereBeUsState shared];
	UpdateAnnotation *annotationFromDictionary = (UpdateAnnotation *) [userKeyToAnnotation objectForKey:state.preferredUserKey];
	UpdateAnnotation *annotation = annotationFromDictionary;
	
	if (annotationFromDictionary == nil)
	{
		// an annotation for this username doesn't yet exist. Create it.
		annotation = [UpdateAnnotation updateAnnotationWithDictionary:[NSDictionary dictionary]];
	}
	
	annotation.displayName = state.preferredDisplayName;
	annotation.profileImageURL = state.preferredProfileImageURL;
	annotation.largeProfileImageURL = state.preferredLargeProfileImageURL;
	annotation.serviceType = state.preferredServiceType;
	annotation.serviceURL = state.preferredServiceURL;
	annotation.idOnService = state.preferredServiceId;
	annotation.message = state.lastMessage;
	[annotation setLatitude:currentCoordinate.latitude longitude:currentCoordinate.longitude];
	annotation.visited = NO;
	
	if (annotationFromDictionary == nil)
	{
		[userKeyToAnnotation setObject:annotation forKey:state.preferredUserKey];
		[self.mapView addAnnotation:annotation];
	}
	
	// force the map to redraw!
	[self forceAnnotationsToUpdate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// STEP 0: reject any coordinates older than, say, three minutes
	if (fabs([newLocation.timestamp timeIntervalSinceNow]) > (3.0 * 60.0))
	{
		return;
	}

	#if TARGET_IPHONE_SIMULATOR
	//	CLLocationCoordinate2D university_zoka_coffee_seattle_wa;
	//	university_zoka_coffee_seattle_wa.latitude = 47.665916;
	//	university_zoka_coffee_seattle_wa.longitude = -122.297361;	
	//	newLocation = [[[CLLocation alloc] initWithCoordinate:university_zoka_coffee_seattle_wa altitude:newLocation.altitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy timestamp:newLocation.timestamp] autorelease];	
	CLLocationCoordinate2D middle_of_ravenna_park_seattle_wa;
	middle_of_ravenna_park_seattle_wa.latitude = 47.67138773385131;
	middle_of_ravenna_park_seattle_wa.longitude = -122.3053327202797;
	newLocation = [[[CLLocation alloc] initWithCoordinate:middle_of_ravenna_park_seattle_wa altitude:newLocation.altitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy timestamp:newLocation.timestamp] autorelease];
	#endif
	
	// STEP 1: if we have yet to see a valid coordinate, 
	// zoom in to that location on the map
	if (!hasCoordinate)
	{
		hasCoordinate = YES;
		bestHorizontalAccuracy = newLocation.horizontalAccuracy;
		[self centerAndZoomOnCoordinate:newLocation.coordinate animated:YES];
	}
	
	// STEP 2: if the accuracy of this coordinate is more than 200% of 
	// the previously best seen accuracy, reject the coordinate.
	if (newLocation.horizontalAccuracy > (bestHorizontalAccuracy * 2.0))
	{
		return;
	}
	
	// (and remember the best accuracy, if it has changed)
	if (newLocation.horizontalAccuracy < bestHorizontalAccuracy)
	{
		bestHorizontalAccuracy = newLocation.horizontalAccuracy;
	}
	
	// STEP 3: update our internal notion of where the user is
	currentCoordinate = newLocation.coordinate;
	[self updateUserAnnotationWithCoordinate:currentCoordinate];
	
	// STEP 4: if necessary, kick off syncing with the service
	[self startSyncingWithService];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	// If we have yet to recieve a location, we probably got here as a result
	// of the user saying "Don't Allow" to location updates. We should 
	// let them know what this won't do much for them.
	if (currentCoordinate.latitude == 0.0 && currentCoordinate.longitude == 0.0)
	{
		encounteredLocationFailure = YES;
		[locationManager stopUpdatingLocation];
		[Utilities displayModalAlertWithTitle:@"Can't Get Location" message:@"You have chosen not to share your location. Your friends won't be able to see where you are. Please consider turning on location services." buttonTitle:@"OK" delegate:nil];
		
		// go ahead and show me my friends, anyway -- basically, force the issue.
		hasCoordinate = YES;
		[self startSyncingWithService];
	}
}


//------------------------------------------------------------------
// UIViewController overrides
//------------------------------------------------------------------

- (void)credentialsChanged:(NSNotification*)notification
{
	[self stopSyncingWithService];		
	[self clearAllAnnotations];
	
	WhereBeUsState *state = [WhereBeUsState shared];
	if ([state hasAnyCredentials] && (currentCoordinate.latitude != 0.0 || currentCoordinate.longitude != 0.0))
	{
		// immediately put our user back
		[self updateUserAnnotationWithCoordinate:currentCoordinate];
		
		// immediately sync
		[self startSyncingWithService];		
	}
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self != nil) 
	{
		// set up basic state
		hasCoordinate = NO;
		userKeyToAnnotation = [[NSMutableDictionary dictionaryWithCapacity:1] retain];

		// build our location manager
		locationManager = [[CLLocationManager alloc] init];
		locationManager.distanceFilter = 20.0; /* don't update unless you've moved 20 meters or more */
		locationManager.desiredAccuracy = kCLLocationAccuracyBest; /* i think we definitely want this for our purposes, despite battery drain */
		locationManager.delegate = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(credentialsChanged:) name:CREDENTIALS_CHANGED object:nil];		
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];	
	if (!encounteredLocationFailure)
	{
		[locationManager startUpdatingLocation];
	}
	[self startSyncingWithService];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	[locationManager stopUpdatingLocation];
	[self stopSyncingWithService];
}

- (void)dealloc
{
	self.mapView = nil;
	self.backSideButton = nil;
	self.chatButton = nil;
	
	[userKeyToAnnotation release];	
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[self stopSyncingWithService];
	
    [super dealloc];
}



@end
