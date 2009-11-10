//
//  UpdateAnnotationView.h
//  TweetSpot
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
	
	id<TweetSpotAnnotationManager> annotationManager;
	
	// state necessary for drawing the expanded annotation view
	// in such a way that it fits cleanly on the screen, regardless
	// of where the underlying map coordinate is located -- a bit
	// tricky, yes, but I'm pretty convinced this is as easy as it gets
	CGFloat expansion_viewWidth;
	CGFloat expansion_contentWidth;
	CGFloat expansion_contentOriginX;
	CGFloat expansion_downArrowX;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationManager:(id<TweetSpotAnnotationManager>)theAnnotationManager;

@end
