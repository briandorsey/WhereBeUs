//
//  AsyncImageView.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/8/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "AsyncImageView.h"


@implementation AsyncImageView

- (void)setDefaultImage:(UIImage *)theDefaultImage urlToLoad:(NSString *)theUrlToLoad alternateUrlToLoad:(NSString *)theAlternateUrlToLoad
{
	if (loadedImageView != nil)
	{
		return;
	}
	
	settingImage = YES;
	defaultImageView = [[UIImageView alloc] initWithImage:theDefaultImage];
	defaultImageView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	defaultImageView.contentMode = UIViewContentModeScaleAspectFill;
	[defaultImageView setOpaque:NO];
	[defaultImageView setAlpha:1.0];
	[self addSubview:defaultImageView];
	
	urlToLoad = [theUrlToLoad retain];
	alternateUrlToLoad = [theAlternateUrlToLoad retain];
	loadedImageView = nil;
	
	[[AsyncImageCache shared] loadImageForURL:theUrlToLoad delegate:self];
	settingImage = NO;
}

- (void)dealloc
{
	[[AsyncImageCache shared] clearImageForURL:urlToLoad];	
	// no clearing the alternate, which is generally the small URL -- maybe I should though?
	[defaultImageView removeFromSuperview];
	[defaultImageView release];	
	[urlToLoad release];
	[alternateUrlToLoad release];
	[loadedImageView removeFromSuperview];
	[loadedImageView release];
	[super dealloc];
}


//---------------------------------------------------------------------
// AsyncImageCache Delegate
//---------------------------------------------------------------------

- (void)asyncImageCacheLoadedImage:(UIImage *)image forURL:(NSString *)url
{
	// sanity check
	NSAssert(loadedImageView == nil, @"Loaded image view must be nil here.");
	
	// did we fail? go ahead and try our alternate URL, if provided.
	if (image == nil && [url isEqualToString:urlToLoad])
	{
		[[AsyncImageCache shared] loadImageForURL:alternateUrlToLoad delegate:self];
		return;
	}
	else if (image == nil)
	{
		// can't do anything about it. Fail.
		return;
	}
	
	// Create our new subview
	loadedImageView = [[UIImageView alloc] initWithImage:image];
	loadedImageView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	loadedImageView.contentMode = UIViewContentModeScaleAspectFill;
	[loadedImageView setOpaque:NO];
	[loadedImageView setAlpha:0.0];
	[self addSubview:loadedImageView];
	
	// Should we fade? If we already had this image available, no... otherwise, yes.
	if (settingImage)
	{
		[loadedImageView setAlpha:1.0];
		[loadedImageView setOpaque:YES];
	}
	else
	{
		// animate a fade transition
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5];
		defaultImageView.alpha = 0.0;
		loadedImageView.alpha = 1.0;
		[UIView commitAnimations];		
	}
}

@end
