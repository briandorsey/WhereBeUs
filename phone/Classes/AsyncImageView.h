//
//  AsyncImageView.h
//  WhereBeUs
//
//  Created by Dave Peck on 1/8/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncImageCache.h"

@interface AsyncImageView : UIView<AsyncImageCacheDelegate> {
	BOOL settingImage;	
	UIImageView *defaultImageView;		
	NSString *urlToLoad;
	NSString *alternateUrlToLoad;
	UIImageView *loadedImageView;
}

- (void)setDefaultImage:(UIImage *)theDefaultImage urlToLoad:(NSString *)theUrlToLoad alternateUrlToLoad:(NSString *)theAlternateUrlToLoad;

@end
