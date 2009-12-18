//
//  UpdateAnnotationView.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/5/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AsyncImageCache.h"
#import "MapViewController.h"

@interface UpdateAnnotationView : MKAnnotationView<AsyncImageCacheDelegate> {
	UIImage *twitterUserIcon;
	CGFloat twitterIconPercent; /* for when we're fading between the default icon and the twitter user icon */
	BOOL initializing;
	NSTimer *fadeTimer;
	
	CGRect pressRect;
	BOOL pressed;
	BOOL trackingPress;
	
	id<WhereBeUsAnnotationManager> annotationManager;
	
	// where should the "down arrow" be located in our expanded
	// annotation? by default, we want to center it, but if the
	// expanded annotation doesn't fit on the map when centered,
	// then we'll draw the downArrow somewhere else (and set
	// our annotation view's centerOffset accordingly, too)
	CGFloat expansion_downArrowX;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationManager:(id<WhereBeUsAnnotationManager>)theAnnotationManager;

@end
