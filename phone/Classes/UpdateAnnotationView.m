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

#define BUBBLE_PNG_WIDTH 55.0
#define BUBBLE_PNG_HEIGHT 68.0
#define IMAGE_LEFT 9.0
#define IMAGE_TOP 5.0
#define IMAGE_WIDTH 37.0
#define IMAGE_HEIGHT 37.0

#define kFadeTimerSeconds 0.025
#define kFadeIncrement 0.1

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
		initializing = YES;		
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BUBBLE_PNG_WIDTH, BUBBLE_PNG_HEIGHT);
		self.opaque = NO;
		twitterUserIcon = nil;
		twitterIconPercent = 0.0;
		
		UpdateAnnotation *updateAnnotation = (UpdateAnnotation *) self.annotation;
		[[AsyncImageCache shared] loadImageForURL:updateAnnotation.twitterProfileImageURL delegate:self];		
		
		self.canShowCallout = YES; /* todo build our own callout */
		initializing = NO;
	}
	return self;
}

- (void)dealloc
{
	[fadeTimer invalidate];
	[fadeTimer release];
	fadeTimer = nil;
	
	[twitterUserIcon release];
	twitterUserIcon = nil;
	
	[super dealloc];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	[fadeTimer invalidate];
	[fadeTimer release];
	fadeTimer = nil;

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
		[[UpdateAnnotationView defaultUserIcon] drawAtPoint:CGPointMake(IMAGE_LEFT, IMAGE_TOP)];
	}
	else
	{
		if (twitterIconPercent >= 1.0)
		{
			[twitterUserIcon drawInRect:CGRectMake(IMAGE_LEFT, IMAGE_TOP, IMAGE_WIDTH, IMAGE_HEIGHT)];
		}
		else
		{
			[twitterUserIcon drawInRect:CGRectMake(IMAGE_LEFT, IMAGE_TOP, IMAGE_WIDTH, IMAGE_HEIGHT) blendMode:kCGBlendModeNormal alpha:twitterIconPercent];
			[[UpdateAnnotationView defaultUserIcon] drawInRect:CGRectMake(IMAGE_LEFT, IMAGE_TOP, IMAGE_WIDTH, IMAGE_HEIGHT) blendMode:kCGBlendModeNormal alpha:1.0 - twitterIconPercent];
		}
	}
}

- (void)fadeTimerFired:(NSTimer *)timer
{
	twitterIconPercent += kFadeIncrement;
	if (twitterIconPercent >= 1.0)
	{
		twitterIconPercent = 1.0;
		[fadeTimer invalidate];
		[fadeTimer release];
		fadeTimer = nil;
	}
	[self setNeedsDisplay];
}

- (void)fadeInNewUserIcon
{
	if (initializing)
	{
		// if we're just setting up and we have the icon,
		// don't do the fade in -- that's just a waste.
		twitterIconPercent = 1.0;
		return;
	}
	
	if (fadeTimer != nil)
	{
		[fadeTimer invalidate];
		[fadeTimer release];
		fadeTimer = nil;
	}
	
	twitterIconPercent = 0.0;
	fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:kFadeTimerSeconds target:self selector:@selector(fadeTimerFired:) userInfo:nil repeats:YES] retain];
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
		[self fadeInNewUserIcon];
	}

	// force full redraw
	[self setNeedsDisplay];
}


@end
