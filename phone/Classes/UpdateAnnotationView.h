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
	
	BOOL expanded;
}

+ (UpdateAnnotationView *)uniqueExpandedView;
+ (void)setUniqueExpandedView:(UpdateAnnotationView *)newUniqueExpandedView;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationManager:(id<TweetSpotAnnotationManager>)theAnnotationManager;

- (BOOL)expanded;
- (void)setExpanded:(BOOL)newExpanded animated:(BOOL)animated;

@end
