//
//  AsyncImageCache.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/5/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "AsyncImageCache.h"

@implementation AsyncImageCache

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		urlToImage = [[NSMutableDictionary dictionaryWithCapacity:1] retain];
		
		// see header file for explanation of why we're using a CFMutableDictionary instead of a NSMutableDictionary
		connectionToDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		CFRetain(connectionToDictionary);
	}
	return self;
}

- (void)dealloc
{
	// clean up any/all open connections	
	if (connectionToDictionary != nil)
	{
		CFIndex count = CFDictionaryGetCount(connectionToDictionary);
		
		// cancel all running connections
		if (count > 0)
		{
			void **keys = malloc(sizeof(void *) * count);
			for (CFIndex i = 0; i < count; i++)
			{
				NSURLConnection *connection = keys[i];
				[connection cancel];				
			}
			free(keys);
		}
		
		// clean out all connections to force releases
		CFDictionaryRemoveAllValues(connectionToDictionary);

		// done with the dictionary! done with the chart!
		CFRelease(connectionToDictionary);
		connectionToDictionary = nil;
	}
		
	// clean up our cache
	[urlToImage release];
	
	[super dealloc];
}

+ (AsyncImageCache *)shared
{
	static AsyncImageCache *_shared;
	
	@synchronized (self)
	{
		if (_shared == nil)
		{
			_shared = [[AsyncImageCache alloc] init];
		}		
	}
	
	return _shared;
}

- (UIImage *)imageForURL:(NSString *)url
{
	return [urlToImage objectForKey:url];
}

- (void)loadImageForURL:(NSString *)urlString delegate:(id<AsyncImageCacheDelegate>)delegate
{
	UIImage *image = [urlToImage objectForKey:urlString];

	// see if it is in our cache already
	if (image != nil)
	{
		[delegate asyncImageCacheLoadedImage:image forURL:urlString];
		return;
	}
	
	// validate the URL
	NSURL *url = nil;
	@try
	{
		url = [NSURL URLWithString:urlString];
	}
	@catch (NSException *e)
	{
		url = nil;
	}
	
	if (url == nil)
	{
		[delegate asyncImageCacheLoadedImage:nil forURL:urlString];
		return;
	}
	
	// create a new request and connection
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	NSMutableData *data = [NSMutableData dataWithCapacity:2048];
	NSMutableDictionary *dictionary = [NSMutableDictionary 
									   dictionaryWithObjectsAndKeys:urlString, @"urlString", 
									   data, @"data", 
									   delegate, @"delegate", /* it is okay to retain the delegate in this one case... in general, it is not */
									   nil];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	CFDictionarySetValue(connectionToDictionary, connection, dictionary);
}

- (void)clearImageForURL:(NSString *)url
{
	@try 
	{
		[urlToImage removeObjectForKey:url];
	}
	@catch (NSException * e) 
	{
		/* intentional no-op */
	}
	@finally 
	{
		/* intentional no-op */
	}
}

- (void)clearAllImages
{
	[urlToImage removeAllObjects];
}


#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData 
{
	NSMutableDictionary *dictionary = (NSMutableDictionary *) CFDictionaryGetValue(connectionToDictionary, (const void*)connection);
	NSMutableData *data = (NSMutableData *) [dictionary objectForKey:@"data"];
	[data appendData:incrementalData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// grab the information about this connection that we need to report an error
	NSMutableDictionary *dictionary = (NSMutableDictionary *) CFDictionaryGetValue(connectionToDictionary, (const void*)connection);
	id<AsyncImageCacheDelegate> delegate = (id<AsyncImageCacheDelegate>) [dictionary objectForKey:@"delegate"];
	NSString *urlString = (NSString *) [dictionary objectForKey:@"urlString"];	
	
	// report the error
	[delegate asyncImageCacheLoadedImage:nil forURL:urlString];
	
	// clean up this connection
	CFDictionaryRemoveValue(connectionToDictionary, (const void*)connection);
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
	// grab the data received
	NSMutableDictionary *dictionary = (NSMutableDictionary *) CFDictionaryGetValue(connectionToDictionary, (const void*)connection);
	NSMutableData *data = (NSMutableData *) [dictionary objectForKey:@"data"];
	NSString *urlString = (NSString *) [dictionary objectForKey:@"urlString"];
	id<AsyncImageCacheDelegate> delegate = (id<AsyncImageCacheDelegate>) [dictionary objectForKey:@"delegate"];

	// attempt to create an image from the data
	UIImage *newImage = nil;
	@try
	{
		newImage = [UIImage imageWithData:data];
	}
	@catch (NSException *e)
	{
		newImage = nil;
	}
	
	// success? add it to our cache.
	if (newImage != nil)
	{
		[urlToImage setObject:newImage forKey:urlString];
	}
	
	// send notification to our delegate (nil image indicates failure)
	[delegate asyncImageCacheLoadedImage:newImage forURL:urlString];
	
	// clean up our out-of-band connection information
	CFDictionaryRemoveValue(connectionToDictionary, (const void*)connection);
	[connection release];
}

@end
