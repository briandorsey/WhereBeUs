//
//  JsonConnection.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "JsonConnection.h"
#import "JsonResponse.h"
#import "JSON.h"
#import "NSData+Base64Encoding.h"

static NSString *const kREFERER_URL = @"http://www.wherebe.us/iphone/";
static NSString *const kREFERER_HEADER = @"Referer";

@implementation JsonConnection

+ (id)connectionWithURL:(NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData
{
	return [JsonConnection connectionWithURL:theURL delegate:theDelegate userData:theUserData authUsername:nil authPassword:nil];
}

+ (id)connectionWithURL:(NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData authUsername:(NSString *)theAuthUsername authPassword:(NSString *)theAuthPassword
{
	return [[[JsonConnection alloc] initWithURL:theURL delegate:theDelegate userData:theUserData authUsername:theAuthUsername authPassword:theAuthPassword postData:nil] autorelease];
}

+ (id)postConnectionWithURL:(NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData postData:(NSData *)postData
{
	return [[[JsonConnection alloc] initWithURL:theURL delegate:theDelegate userData:theUserData authUsername:nil authPassword:nil postData:postData] autorelease];
}

- (id)initWithURL: (NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData authUsername:(NSString *)theAuthUsername authPassword:(NSString *)theAuthPassword postData:(NSData *)postData
{
	self = [super init];
	if (self != nil) 
	{
		data = nil;
		response = nil;
		delegate = theDelegate;
		userData = [theUserData retain];

		NSURL *finalURL = [NSURL URLWithString:theURL];	
		// NSAssert(finalURL != nil, @"BROKEN URL");
				
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:finalURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
		if ((theAuthUsername != nil) && (theAuthPassword != nil))
		{
			NSString *usernameAndPassword = [NSString stringWithFormat:@"%@:%@", theAuthUsername, theAuthPassword];
			NSString *base64 = [[NSData dataWithBytes:[usernameAndPassword cStringUsingEncoding:NSASCIIStringEncoding] length:[usernameAndPassword length]] base64Encoding];
			[request addValue:[NSString stringWithFormat:@"Basic %@", base64] forHTTPHeaderField:@"Authorization"];			
		}
		[request setValue:kREFERER_URL forHTTPHeaderField:kREFERER_HEADER];
		
		if (postData != nil)
		{
			[request setHTTPMethod:@"POST"];
			[request setHTTPBody:postData];
		}
		
		// Be sure to pre-flight all requests
		if ([NSURLConnection canHandleRequest:request])
		{		
			connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
			// NSLog(@"JsonConnection: started loading (%@)", connection);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		}
		else
		{
			[delegate jsonConnection:self didFailWithError:[NSError errorWithDomain:@"JsonConnection" code:JsonConnectionError_Network_Failure userInfo:nil] userData:userData];
		}
	}	
	return self;
}	

- (void)cancel 
{
	[connection cancel];
}

- (void)dealloc 
{
	[connection cancel];
	[userData release];
	[connection release];	
	[data release];
	[response release];	
    [super dealloc];
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData 
{
    if (data == nil) 
	{
		data = [[NSMutableData alloc] initWithCapacity:2048];
    }
	
    [data appendData:incrementalData];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse
{
	// according to the URL Loading System guide, it is possible to receive 
	// multiple responses in some cases (server redirects; multi-part MIME responses; etc)
	[response release];
	response = [theResponse retain];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)theError
{
	[data release];
	data = nil;
	
	[response release];
	response = nil;
	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[delegate jsonConnection:self didFailWithError:[NSError errorWithDomain:@"JsonConnection" code:JsonConnectionError_Network_Failure userInfo:nil] userData:userData];	
}
 
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection 
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (data == nil || response == nil)
	{
		NSLog(@"data was: %@ and response was: %@", data, response);
		[delegate jsonConnection:self didFailWithError:[NSError errorWithDomain:@"JsonConnection" code:JsonConnectionError_Network_Failure userInfo:nil] userData:userData];
		[connection release];
		connection = nil;
		return;
	}
	
	// determine the proper encoding based on the HTTP response, if available
	// (otherwise, assume UTF-8 encoding.)
	NSString *textEncodingName = [response textEncodingName];
	NSStringEncoding likelyEncoding = NSUTF8StringEncoding;
	if (textEncodingName != nil)
	{
		CFStringRef cfsr_textEncodingName = (CFStringRef) textEncodingName;
		CFStringEncoding cf_encoding = CFStringConvertIANACharSetNameToEncoding(cfsr_textEncodingName);
		likelyEncoding = CFStringConvertEncodingToNSStringEncoding(cf_encoding);
	}
	
	// grab the JSON data as a string
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:likelyEncoding];
	
	// turn this on for some really helpful debugging ... NSLog(@"%@", jsonString);
	
	// attempt to create a response (nil indicates failure)
	id jsonResponse = [JsonResponse jsonResponseWithString:jsonString];
	
	// clean up
	[jsonString release];
	[data release];
	data = nil;
	
    [connection release];
    connection = nil;
	
	[response release];
	response = nil;
	
	// send an appropriate message to our delegate
	if (jsonResponse != nil)
	{
		[delegate jsonConnection:self didReceiveResponse:jsonResponse userData:userData];
	}
	else
	{
		[delegate jsonConnection:self didFailWithError:[NSError errorWithDomain:@"JsonConnection" code:JsonConnectionError_Invalid_Json userInfo:nil] userData:userData];
	}
}

@end
