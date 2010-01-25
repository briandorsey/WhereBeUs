//
//  UnderlineLabel.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/24/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "UnderlineButton.h"

@implementation UnderlineButton 

- (void)drawRect:(CGRect)rect 
{ 
    [super drawRect:rect]; 
	
	// TODO XXX davepeck :: I don't understand why these are necessary
	// ... and also, they're clearly tied to the font size. So this is a big ugly hack for now.
	const CGFloat FUDGE_MOVE_RIGHT = 8.0;
	const CGFloat FUDGE_LESS_LENGTH = 1.0;
	
	// Get the size of the label 
	CGSize dynamicSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(99999, 99999) lineBreakMode:self.titleLabel.lineBreakMode]; 
	
	// Set the line info
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.2980 green:0.3372549 blue:0.42352941 alpha:0.75] CGColor]);
	CGContextSetLineWidth(context, 0.50); 
	
	// Figure out the origin
	CGPoint origin = CGPointMake(0, 0);		
	if (self.titleLabel.textAlignment == UITextAlignmentCenter) 
	{
		origin.x = (self.frame.size.width / 2) - (dynamicSize.width / 2); 
	}
	else if (self.titleLabel.textAlignment == UITextAlignmentRight) 
	{
		origin.x = self.frame.size.width - dynamicSize.width; 		
	}
	else
	{
		origin.x += self.titleEdgeInsets.left + FUDGE_MOVE_RIGHT;
		dynamicSize.width = dynamicSize.width - FUDGE_LESS_LENGTH;
	}
	origin.y = (self.frame.size.height / 2) + (dynamicSize.height / 2); 
	
	// Draw the line 
	CGContextMoveToPoint(context, origin.x, origin.y); 
	CGContextAddLineToPoint(context, origin.x + dynamicSize.width, origin.y); 
	CGContextStrokePath(context); 
} 

- (void)dealloc 
{ 
    [super dealloc]; 
} 

@end 