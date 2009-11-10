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

@interface UpdateAnnotationView (Private)
- (void)transitionToExpanded:(BOOL)animated;
- (void)transitionToCollapsed:(BOOL)animated;
@end

@implementation UpdateAnnotationView


//---------------------------------------------------------------------
// Static methods for managing the "one true" expanded annotation
//---------------------------------------------------------------------

static UpdateAnnotationView *_uniqueExpandedView = nil;

+ (UpdateAnnotationView *)uniqueExpandedView
{
	// WARNING: not even kind of thread-safe
	return _uniqueExpandedView;
}

+ (void)setUniqueExpandedView:(UpdateAnnotationView *)newUniqueExpandedView
{
	// WARNING: not even kind of thread-safe
	_uniqueExpandedView = newUniqueExpandedView;
}


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


//---------------------------------------------------------------------
// Initialization & Destruction
//---------------------------------------------------------------------

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier annotationManager:(id<TweetSpotAnnotationManager>)theAnnotationManager
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil)
	{
		initializing = YES;		
		self.opaque = NO;
		annotationManager = theAnnotationManager;		
		twitterUserIcon = nil;
		twitterIconPercent = 0.0;
		expanded = NO;
		
		[self transitionToCollapsed:NO];
		
		UpdateAnnotation *updateAnnotation = (UpdateAnnotation *)annotation;
		[[AsyncImageCache shared] loadImageForURL:updateAnnotation.twitterProfileImageURL delegate:self];		
		
		self.canShowCallout = NO; /* we are the callout! */
		initializing = NO;
		self.exclusiveTouch = YES; /* we are the only ones who get our touches, darnit */
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
	[self transitionToCollapsed:NO];	
}


//---------------------------------------------------------------------
// Geometry Helpers
//---------------------------------------------------------------------

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


//---------------------------------------------------------------------
// Custom View Drawing
//---------------------------------------------------------------------

- (void)drawExpandedRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(context, NO);	
	UpdateAnnotation *updateAnnotation = (UpdateAnnotation *)self.annotation;
	
	//------------------------------------------------
	// Draw Background
	//------------------------------------------------
	
	// compute areas	
	CGRect leftCapRect = CGRectMake(expansion_contentOriginX, 0.0, LEFT_WIDTH, LEFT_HEIGHT);
	CGRect rightCapRect = CGRectMake(expansion_contentWidth + expansion_contentOriginX - RIGHT_WIDTH, 0.0, RIGHT_WIDTH, RIGHT_HEIGHT);
	CGFloat centerImageCenterX = expansion_downArrowX + expansion_contentOriginX;
	CGFloat centerImageX = centerImageCenterX - round(CENTER_WIDTH / 2.0);
	CGRect centerRect = CGRectMake(centerImageX, 0.0, CENTER_WIDTH, CENTER_HEIGHT);
	
	CGFloat leftCapRect_right = GetRectRight(leftCapRect);
	CGFloat centerRect_left = GetRectLeft(centerRect);
	CGRect leftFillRect = CGRectMake(leftCapRect_right, 0.0, centerRect_left - leftCapRect_right, FILL_HEIGHT);
	
	CGFloat rightCapRect_left = GetRectLeft(rightCapRect);
	CGFloat centerRect_right = GetRectRight(centerRect);
	CGRect rightFillRect = CGRectMake(centerRect_right, 0.0, rightCapRect_left - centerRect_right, FILL_HEIGHT);
	
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
	if (image != nil && [url isEqualToString:updateAnnotation.twitterProfileImageURL])
	{
		twitterUserIcon = [image retain];
		[self fadeInNewUserIcon];
	}

	// force full redraw
	[self setNeedsDisplay];
}


//---------------------------------------------------------------------
// Expand/Collapse
//---------------------------------------------------------------------

- (void)transitionToExpanded:(BOOL)animated
{
	// figure out how big our expanded view's visible content will be
	UpdateAnnotation *updateAnnotation = (UpdateAnnotation *)self.annotation;
	CGSize titleSize = [updateAnnotation.title sizeWithFont:[UIFont boldSystemFontOfSize:16.0]];
	CGSize subtitleSize = [updateAnnotation.subtitle sizeWithFont:[UIFont systemFontOfSize:12.0]];
	CGFloat maxTextWidth = (titleSize.width > subtitleSize.width) ? titleSize.width : subtitleSize.width;
	expansion_contentWidth = (LEFT_WIDTH - 6.0) + (RIGHT_WIDTH - 2.0) + (LEFT_WIDTH - 8.0) + (IMAGE_STROKE_WIDTH) + maxTextWidth;
	
	// where are we currently displayed on screen?
	CGRect currentScreenBounds = [annotationManager getScreenBoundsForRect:self.bounds fromView:self];
	CGFloat currentScreenCenterX = currentScreenBounds.origin.x + (currentScreenBounds.size.width / 2.0);
	
	// where will our horizontal extents be, on screen,
	// if we fully expand and put our down-arrow dead center?
	CGFloat futureScreenLeftX = currentScreenCenterX - (expansion_contentWidth / 2.0);
	CGFloat futureScreenRightX = currentScreenCenterX + (expansion_contentWidth / 2.0);
	CGFloat maxScreenRight = [[UIScreen mainScreen] bounds].size.width;

	// do we need to modify our position so we fit on the screen?
	CGFloat adjustX = 0.0;
	if ((futureScreenLeftX < 0) ^ (futureScreenRightX > maxScreenRight))
	{
		if (futureScreenLeftX < 0)
		{
			adjustX = -futureScreenLeftX; /* will be a positive value, aka move to the right */
		}
		else
		{
			adjustX = maxScreenRight - futureScreenRightX; /* will be a negative value, aka move to the left */
		}
	}
	
	// compute where the center of the down arrow should be, relative
	// to wherever we start drawing actual content in the view
	expansion_downArrowX = round((expansion_contentWidth / 2.0) - adjustX);
	
	// let's be careful, though. If we have to adjust too far, our left cap
	// (or right cap) image will overlap with the center/down-arrow image.
	// This calls for: moving the map itself! We want to move the map
	// exactly as many pixels as there is overlap, plus one pixel so that
	// we get a line of "fill" everywhere.
	CGFloat mapMoveX = 0.0;
	CGFloat overlapLeft = (expansion_downArrowX - round(CENTER_WIDTH / 2.0)) - (LEFT_WIDTH + 1.0);
	CGFloat overlapRight = (expansion_downArrowX + round(CENTER_WIDTH / 2.0)) - (expansion_contentWidth - RIGHT_WIDTH + 1.0);
		
	// the down arrow location is affected by our overlap adjustment, if any
	if (overlapLeft <= 0.0)
	{
		mapMoveX = overlapLeft;
		adjustX += overlapLeft;
		expansion_downArrowX = round((expansion_contentWidth / 2.0) - adjustX);
	}
	else if (overlapRight >= 0.0)
	{
		mapMoveX = overlapRight;
		adjustX += overlapRight;
		expansion_downArrowX = round((expansion_contentWidth / 2.0) - adjustX);
	}
	
	// compute the overall width of the view so that the down arrow is centered
	expansion_viewWidth = expansion_contentWidth + (2.0 * fabs(adjustX));
	
	// compute where to start drawing the view's actual content
	expansion_contentOriginX = (adjustX > 0.0) ? (expansion_viewWidth - expansion_contentWidth) : 0.0;
	
	// TODO: (1) restrict annotation sizes to a maximum width (eg 300 wide)
	
	// force a redraw of us.
	self.bounds = CGRectMake(0.0, 0.0, expansion_viewWidth, FIXED_EXPANDED_HOTSPOT_Y * 2);
	[self setNeedsDisplay];		

	if (mapMoveX != 0.0)
	{
		[annotationManager moveMapByDeltaX:mapMoveX deltaY:0.0 forView:self];
	}
	else 
	{
		[annotationManager forceAnnotationsToUpdate];
	}
}

- (void)transitionToCollapsed:(BOOL)animated
{
	self.bounds = CGRectMake(0.0, 0.0, BUBBLE_PNG_WIDTH, BUBBLE_HOTSPOT_Y * 2);	
	[self setNeedsDisplay];		
	[annotationManager forceAnnotationsToUpdate];			
}

- (BOOL)expanded
{
	return expanded;
}

- (void)setExpanded:(BOOL)newExpanded animated:(BOOL)animated
{
	if (newExpanded != expanded)
	{
		if (newExpanded)
		{
			// if there is a currently expanded annotation, shut it down.
			// order of operations is important so that the collaping 
			// annotation doesn't try to do the same.
			UpdateAnnotationView *currentlyExpanded = [UpdateAnnotationView uniqueExpandedView];
			[UpdateAnnotationView setUniqueExpandedView:self];
			[currentlyExpanded setExpanded:NO animated:animated];

			[self transitionToExpanded:animated];
		}
		else
		{
			// if _I_ am the currently expanded annotation, then,
			// because of the order of operations in (newExpanded) above,
			// this means the user tapped _on me_. 
			if ([UpdateAnnotationView uniqueExpandedView] == self)
			{
				[UpdateAnnotationView setUniqueExpandedView:nil];
			}
			
			[self transitionToCollapsed:animated];
		}
		
		expanded = newExpanded;	
	}	
}


//---------------------------------------------------------------------
// Touch Interception
//---------------------------------------------------------------------

// The map behavior is interesting: you only have to hold on top of
// an annotation for maybe 1/4 second and it will show its callout.
// If you don't let go and drag your finger around, other annotations
// that you drag over will actually show _their_ callouts.
//
// I'm not sure if that's the behavior we want here, but I'll try it
// until we have reason to try something else...

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if (expanded)
	{
		return CGRectContainsPoint(CGRectMake(expansion_contentOriginX, 0.0, expansion_contentWidth, CENTER_HEIGHT), point);
	}
	else
	{
		return CGRectContainsPoint(CGRectMake(0.0, 0.0, self.frame.size.width, BUBBLE_PNG_HEIGHT - (BUBBLE_PNG_HEIGHT - BUBBLE_HOTSPOT_Y)), point);
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if ([self pointInside:[touch locationInView:self] withEvent:event])
	{
		if ([touch tapCount] == 1)
		{
			[self setExpanded:!expanded animated:YES];
		}
	}
}

//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//}

@end
