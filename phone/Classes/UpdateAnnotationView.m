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

// NOTE WELL: THIS CODE IS VERY MUCH IN PROGRESS... 
// ...IT IS CURRENTLY "LOCKED" TO THE "EXPANDED" STATE.

#define BUBBLE_PNG_WIDTH 55.0
#define BUBBLE_PNG_HEIGHT 68.0
#define BUBBLE_HOTSPOT_Y 58.0

#define IMAGE_LEFT 9.0
#define IMAGE_TOP 5.0
#define IMAGE_WIDTH 37.0
#define IMAGE_HEIGHT 37.0

#define IMAGE_STROKE_TOP 6.0
#define IMAGE_STROKE_WIDTH 36.0
#define IMAGE_STROKE_HEIGHT 36.0

#define FIXED_EXPANDED_WIDTH 270.0
#define FIXED_EXPANDED_HEIGHT 70.0
#define FIXED_EXPANDED_HOTSPOT_Y 58.0

#define FILL_WIDTH 1.0
#define FILL_HEIGHT 57.0
#define CENTER_WIDTH 41.0
#define CENTER_HEIGHT 70.0
#define LEFT_WIDTH 17.0
#define LEFT_HEIGHT 57.0
#define RIGHT_WIDTH 17.0
#define RIGHT_HEIGHT 57.0

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

+ (UIImage *)leftCapImage
{
	static UIImage *_leftCapImage;
	
	@synchronized (self)
	{
		if (_leftCapImage == nil)
		{
			_leftCapImage = [[UIImage imageNamed:@"left.png"] retain];
		}		
	}
	
	return _leftCapImage;
}

+ (UIImage *)rightCapImage
{
	static UIImage *_rightCapImage;
	
	@synchronized (self)
	{
		if (_rightCapImage == nil)
		{
			_rightCapImage = [[UIImage imageNamed:@"right.png"] retain];
		}		
	}
	
	return _rightCapImage;
}

+ (UIImage *)centerImage
{
	static UIImage *_centerImage;
	
	@synchronized (self)
	{
		if (_centerImage == nil)
		{
			_centerImage = [[UIImage imageNamed:@"center.png"] retain];
		}		
	}
	
	return _centerImage;
}

+ (UIImage *)fillImage
{
	static UIImage *_fillImage;
	
	@synchronized (self)
	{
		if (_fillImage == nil)
		{
			_fillImage = [[UIImage imageNamed:@"fill.png"] retain];
		}		
	}
	
	return _fillImage;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil)
	{
		initializing = YES;		
		// self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, BUBBLE_PNG_WIDTH, BUBBLE_HOTSPOT_Y * 2);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, FIXED_EXPANDED_WIDTH, FIXED_EXPANDED_HOTSPOT_Y * 2);

		self.opaque = NO;
		twitterUserIcon = nil;
		twitterIconPercent = 0.0;
		expanded = YES;
		
		UpdateAnnotation *updateAnnotation = (UpdateAnnotation *) self.annotation;
		[[AsyncImageCache shared] loadImageForURL:updateAnnotation.twitterProfileImageURL delegate:self];		
		
		self.canShowCallout = NO; /* we are the callout! */
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

CGFloat GetRectTop(CGRect rect)
{
	return rect.origin.y;
}

CGFloat GetRectLeft(CGRect rect)
{
	return rect.origin.x;
}

CGFloat GetRectBottom(CGRect rect)
{
	return rect.origin.y + rect.size.height;
}

CGFloat GetRectRight(CGRect rect)
{
	return rect.origin.x + rect.size.width;
}

- (void)drawExpandedRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);	
	UpdateAnnotation *updateAnnotation = (UpdateAnnotation *)self.annotation;
	
	//------------------------------------------------
	// Draw Background
	//------------------------------------------------
	
	// compute areas	
	CGSize frameSize = self.frame.size;
	CGRect leftCapRect = CGRectMake(0.0, 0.0, LEFT_WIDTH, LEFT_HEIGHT);
	CGRect rightCapRect = CGRectMake(frameSize.width - RIGHT_WIDTH, 0.0, RIGHT_WIDTH, RIGHT_HEIGHT);
	CGRect centerRect = CGRectMake(round(frameSize.width / 2.0) - (CENTER_WIDTH / 2.0), 0.0, CENTER_WIDTH, CENTER_HEIGHT);
	
	CGFloat leftCapRect_right = GetRectRight(leftCapRect);
	CGFloat centerRect_left = GetRectLeft(centerRect);
	CGRect leftFillRect = CGRectMake(leftCapRect_right, 0.0, centerRect_left - leftCapRect_right - 1, FILL_HEIGHT);
	
	CGFloat rightCapRect_left = GetRectLeft(rightCapRect);
	CGFloat centerRect_right = GetRectRight(centerRect);
	CGRect rightFillRect = CGRectMake(centerRect_right + 1, 0.0, rightCapRect_left - centerRect_right - 1, FILL_HEIGHT);
	
	// draw areas
	[[UpdateAnnotationView leftCapImage] drawInRect:leftCapRect];
	[[UpdateAnnotationView rightCapImage] drawInRect:rightCapRect];
	[[UpdateAnnotationView centerImage] drawInRect:centerRect];
	[[UpdateAnnotationView fillImage] drawInRect:leftFillRect];
	[[UpdateAnnotationView fillImage] drawInRect:rightFillRect];
	
	//------------------------------------------------
	// Draw User Icon
	//------------------------------------------------
	
	CGRect iconStrokeRect = CGRectMake(GetRectRight(leftCapRect) - 6.0, 6.0, IMAGE_STROKE_WIDTH, IMAGE_STROKE_HEIGHT);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.55);
	CGContextStrokeRect(context, iconStrokeRect);	
	
	CGContextSetShouldAntialias(context, YES);	

	CGRect iconDrawRect = CGRectMake(iconStrokeRect.origin.x + 1.0, 6.0, IMAGE_STROKE_WIDTH - 1, IMAGE_STROKE_HEIGHT -1);
	
	if (twitterUserIcon == nil)
	{
		[[UpdateAnnotationView defaultUserIcon] drawInRect:iconDrawRect];
	}
	else
	{
		if (twitterIconPercent >= 1.0)
		{
			[twitterUserIcon drawInRect:iconDrawRect];
		}
		else
		{
			[twitterUserIcon drawInRect:iconDrawRect blendMode:kCGBlendModeNormal alpha:twitterIconPercent];
			[[UpdateAnnotationView defaultUserIcon] drawInRect:iconDrawRect blendMode:kCGBlendModeNormal alpha:1.0 - twitterIconPercent];
		}
	}	
	
	
	//------------------------------------------------
	// Draw Title
	//------------------------------------------------

	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 0.9);
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.9);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 0.15, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6].CGColor);
	
	CGPoint titlePoint = CGPointMake(GetRectRight(iconDrawRect) + LEFT_WIDTH - 8.0, 5.0);
	[updateAnnotation.title drawAtPoint:titlePoint withFont:[UIFont boldSystemFontOfSize:16.0]];	
	
	
	//------------------------------------------------
	// Draw Subtitle
	//------------------------------------------------
	
	CGPoint subtitlePoint = CGPointMake(titlePoint.x, 26.0);
	[updateAnnotation.subtitle drawAtPoint:subtitlePoint withFont:[UIFont systemFontOfSize:12.0]];		
}

- (void)drawCollapsedRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSetShouldAntialias(context, NO);	
	[[UpdateAnnotationView bubbleImage] drawAtPoint:CGPointMake(0.0, 0.0)];
	CGContextSetShouldAntialias(context, YES);
	
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

- (void)drawRect:(CGRect)rect
{
	if (expanded)
	{
		[self drawExpandedRect:rect];
	}
	else
	{
		[self drawCollapsedRect:rect];
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
