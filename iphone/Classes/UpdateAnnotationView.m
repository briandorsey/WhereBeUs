//
//  UpdateAnnotationView.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/5/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "UpdateAnnotationView.h"
#import "UpdateAnnotation.h"
#import "AsyncImageCache.h"

#define BUBBLE_PNG_WIDTH 55.0
#define BUBBLE_PNG_HEIGHT 68.0
#define BUBBLE_PNG_CENTEROFFSET_Y -23.0

#define IMAGE_LEFT 9.0
#define IMAGE_TOP 5.0
#define IMAGE_WIDTH 37.0
#define IMAGE_HEIGHT 37.0

#define kFadeTimerSeconds 0.025
#define kFadeIncrement 0.1

@implementation UpdateAnnotationView


//---------------------------------------------------------------------
// Static methods for accessing frequently-used images
//---------------------------------------------------------------------

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



//---------------------------------------------------------------------
// Initialization & Destruction
//---------------------------------------------------------------------

- (void)disclosureButtonPressed:(id)sender event:(UIEvent *)event
{
	[annotationManager showDetailViewForAnnotation:self.annotation animated:YES];
}

- (void)setNewAnnotation:(id<MKAnnotation>)newAnnotation
{
	initializing = YES;	
	self.annotation = newAnnotation;	
	self.opaque = NO;
	twitterUserIcon = nil;
	twitterIconPercent = 0.0;
	UpdateAnnotation *updateAnnotation = (UpdateAnnotation *)newAnnotation;
	[[AsyncImageCache shared] loadImageForURL:updateAnnotation.profileImageURL delegate:self];		
	initializing = NO;	
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationManager:(id<WhereBeUsAnnotationManager>)theAnnotationManager
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil)
	{
		annotationManager = theAnnotationManager;
		
		self.bounds = CGRectMake(0.0, 0.0, BUBBLE_PNG_WIDTH, BUBBLE_PNG_HEIGHT);
		self.centerOffset = CGPointMake(0.0, BUBBLE_PNG_CENTEROFFSET_Y);
		
		[self setNewAnnotation:annotation];
		
		// originally we acted as our own callout (see commit c66e5f9b28cee50bdd60294cef487e9437d98344), 
		// but I decided that this was too much work (especially where touch interception was concerned) 
		// for too little visual gain. Removing our expand/collapse visuals from this file allowed me 
		// to remove probably 90% of the code here! --davepeck
		self.canShowCallout = YES; 		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[button addTarget:self action:@selector(disclosureButtonPressed:event:) forControlEvents:UIControlEventTouchUpInside];
		self.rightCalloutAccessoryView = button;
	}
	return self;
}

- (void)dealloc
{
	annotationManager = nil;
	
	[fadeTimer invalidate];
	[fadeTimer release];
	fadeTimer = nil;
	
	[twitterUserIcon release];
	twitterUserIcon = nil;
	
	[super dealloc];
}


//---------------------------------------------------------------------
// MKAnnotationView overrides
//---------------------------------------------------------------------

- (void)prepareForReuse
{
	[super prepareForReuse];
	[fadeTimer invalidate];
	[fadeTimer release];
	fadeTimer = nil;

	[twitterUserIcon release];
	twitterUserIcon = nil;
	
	twitterIconPercent = 0.0;		
	self.bounds = CGRectMake(0.0, 0.0, BUBBLE_PNG_WIDTH, BUBBLE_PNG_HEIGHT);
	self.centerOffset = CGPointMake(0.0, BUBBLE_PNG_CENTEROFFSET_Y);
}


//---------------------------------------------------------------------
// Custom View Drawing
//---------------------------------------------------------------------

- (void)drawRect:(CGRect)rect
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


//---------------------------------------------------------------------
// Fade Management For User Icon
//---------------------------------------------------------------------

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


//---------------------------------------------------------------------
// AsyncImageCache Delegate
//---------------------------------------------------------------------

- (void)asyncImageCacheLoadedImage:(UIImage *)image forURL:(NSString *)url
{
	// just in case
	[twitterUserIcon release];
	twitterUserIcon = nil;

	// remember this image, if it corresponds to the expected URL
	UpdateAnnotation *updateAnnotation = (UpdateAnnotation *) self.annotation;
	if (image != nil && [url isEqualToString:updateAnnotation.profileImageURL])
	{
		twitterUserIcon = [image retain];
		[self fadeInNewUserIcon];
	}

	// force full redraw
	[self setNeedsDisplay];
}

@end
