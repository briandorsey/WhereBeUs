//
//  CustomLoginButton.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "LoginButtonView.h"


@implementation LoginButtonView

- (void)drawRect:(CGRect)rect
{
	CGRect rrect = self.bounds;
    rrect.size.height = rrect.size.height - 2.0;
    rrect.size.width = rrect.size.width - 2.0;
    rrect.origin.x = rrect.origin.x + (2.0 / 2);
    rrect.origin.y = rrect.origin.y + (2.0 / 2);
	
    CGFloat radius = 10.0;
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
	
	CGContextRef context = UIGraphicsGetCurrentContext();	
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.33);	
    CGContextSetLineWidth(context, 2.0);
	
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
