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

@interface UpdateAnnotationView : MKAnnotationView<AsyncImageCacheDelegate> {
	UIImage *twitterUserIcon;
	CGFloat twitterIconPercent; /* for when we're fading between the default icon and the twitter user icon */
	BOOL initializing;
	NSTimer *fadeTimer;
	
	BOOL expanded;
}

@end
