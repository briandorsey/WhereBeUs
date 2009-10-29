//
//  AsyncImageView.m
//  WalkScore
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import "AsyncImageView.h"

// This class demonstrates how the URL loading system can be used to make a UIView subclass
// that can download and display an image asynchronously so that the app doesn't block or freeze
// while the image is downloading. It works fine in a UITableView or other cases where there
// are multiple images being downloaded and displayed all at the same time. 

@implementation AsyncImageView

@synthesize delegate;

#pragma mark Private

- (void)dealloc 
{
	delegate = nil;
	[connection cancel]; //in case the URL is still downloading
	[connection release];	
	[data release]; 	
    [super dealloc];
}

- (void)addImageViewForImage:(UIImage *)newImage
{
	//make an image view for the image
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:newImage] autorelease];
	
	//make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
	
	[self addSubview:imageView];
	imageView.frame = self.bounds;
	[imageView setNeedsLayout];
	[self setNeedsLayout];	
}


#pragma mark Public API

- (void)loadImageFromURL:(NSURL *)url 
{
	if (connection != nil) 
	{
		//in case we are downloading a 2nd image		
		[connection release]; 
	}	
	
	if (data != nil) 
	{ 
		[data release]; 
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
}

- (void)clearImage 
{
	if ([[self subviews] count] > 0) 
	{
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //remove it (releases it also)
	}
}

- (UIImage *)image 
{
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}

- (void)setImage:(UIImage *)newImage 
{
	[self clearImage];
	[self addImageViewForImage:newImage];
	[delegate asyncImageView:self didFinishLoadingImage:YES];
}


#pragma mark Async IO Callbacks

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{
	if (data == nil) 
	{ 
		data = [[NSMutableData alloc] initWithCapacity:2048]; 
	}
	
	[data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
	//so self data now has the complete image 
	[connection release];
	connection = nil;
	
	[self clearImage];
	[self addImageViewForImage:[UIImage imageWithData:data]];
	
	[data release]; //don't need this any more, its in the UIImageView now
	data = nil;	
	
	[delegate asyncImageView:self didFinishLoadingImage:YES];
}

@end
