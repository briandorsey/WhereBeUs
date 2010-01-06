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
	id<WhereBeUsAnnotationManager> annotationManager;	
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationManager:(id<WhereBeUsAnnotationManager>)theAnnotationManager;

@end
