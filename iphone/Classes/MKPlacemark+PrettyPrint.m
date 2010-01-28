//
//  MKPlacemark+PrettyPrint.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/10/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "MKPlacemark+PrettyPrint.h"
#import "NSObject+SBJSON.h"


@implementation MKPlacemark (PrettyPrint)

- (NSString *)prettyPrint
{
	// TODO this code is messy and not as compact as it should be --dave	
	NSString *prettyPrinted = nil;
	
	if (self.subLocality && [self.subLocality length] > 0) 
	{
		if ([@"US" isEqualToString:self.countryCode])
		{
			if (self.thoroughfare && [self.thoroughfare length] > 0)
			{
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@, %@", self.thoroughfare, self.subLocality, self.locality, self.administrativeArea];
			}
			else
			{								 
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@", self.subLocality, self.locality, self.administrativeArea];
			}
		}
		else
		{
			if (self.thoroughfare && [self.thoroughfare length] > 0)
			{
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@, %@, %@", self.thoroughfare, self.subLocality, self.locality, self.administrativeArea, self.country];
			}
			else
			{
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@, %@", self.subLocality, self.locality, self.administrativeArea, self.country];
			}
		}
	}
	else
	{
		if ([@"US" isEqualToString:self.countryCode])
		{
			if (self.thoroughfare && [self.thoroughfare length] > 0)
			{
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@", self.thoroughfare, self.locality, self.administrativeArea];
			}
			else
			{
				prettyPrinted = [NSString stringWithFormat:@"%@, %@", self.locality, self.administrativeArea];
			}
		}
		else
		{
			if (self.thoroughfare && [self.thoroughfare length] > 0)
			{			
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@, %@", self.thoroughfare, self.locality, self.administrativeArea, self.country];				
			}
			else
			{
				prettyPrinted = [NSString stringWithFormat:@"%@, %@, %@", self.locality, self.administrativeArea, self.country];
			}
		}
	}
	
	return prettyPrinted;
}

@end
