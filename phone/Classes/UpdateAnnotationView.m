//
//  UpdateAnnotationView.m
//  TweetSpot
//
//  Created by Dave Peck on 11/5/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "UpdateAnnotationView.h"
#import "UpdateAnnotation.h"
#import "AsyncImageCache.h"

#define BUBBLE_PNG_WIDTH 53.0
#define BUBBLE_PNG_HEIGHT 61.0


@implementation UpdateAnnotationView

+ (UIImage *)bubbleImage
{
	static UIImage *_bubbleImage;
	
	@synchronized (self)
	{
		if (_bubbleImage == nil)
		{
			_bubbleImage = [[UIImage imageNamed:@"bubble.png"] retain];
		}		
	}
	
	return _bubbleImage;
}

+ (UIImage *)defaultUserIcon
{
	static UIImage *_defaultUserIcon;
	
	@synchronized (self)
	{
		if (_defaultUserIcon == nil)
		{
			_defaultUserIcon = [[UIImage imageNamed:@"default37.png"] retain];
		}		
	}
	
	return _defaultUserIcon;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil)
	{
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BUBBLE_PNG_WIDTH, BUBBLE_PNG_HEIGHT);
		self.opaque = NO;
		twitterUserIcon = nil;
		
		UpdateAnnotation *updateAnnotation = (UpdateAnnotation *) self.annotation;		
		[[AsyncImageCache shared] loadImageForURL:updateAnnotation.twitterProfileImageURL delegate:self];		
		
		// TODO XXX build our own callout (it is strange to have callout-on-callout this way)
		self.canShowCallout = YES;
	}
	return self;
}

- (void)dealloc
{
	[twitterUserIcon release];
	[super dealloc];
}

- (void)prepareForReuse
{
	[super prepareForReuse];

	[twitterUserIcon release];
	twitterUserIcon = nil;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
	[[UpdateAnnotationView bubbleImage] drawAtPoint:CGPointMake(0.0, 0.0)];
	
	if (twitterUserIcon == nil)
	{
		[[UpdateAnnotationView defaultUserIcon] drawAtPoint:CGPointMake(8.0, 5.0)];
	}
	else
	{
		[twitterUserIcon drawInRect:CGRectMake(8.0, 5.0, 37.0, 37.0)];
	}
}

- (void)asyncImageCacheLoadedImage:(UIImage *)image forURL:(NSString *)url
{
	NSLog(@"Got async image for url %@: %@", url, image);
	
	// just in case
	[twitterUserIcon release];
	twitterUserIcon = nil;

	// remember this image, if it corresponds to the expected URL
	UpdateAnnotation *updateAnnotation = (UpdateAnnotation *) self.annotation;
	if (image != nil && [url isEqualToString:updateAnnotation.twitterProfileImageURL])
	{
		twitterUserIcon = [image retain];
	}

	// force full redraw
	[self setNeedsDisplay];
}


@end
