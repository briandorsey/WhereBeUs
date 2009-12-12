//
//  TwitterService.m
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "ConnectionHelper.h"
#import "JsonResponse.h"
#import "NSObject+SBJSON.h"
#import "NSDictionary+PostData.h"
#import "WhereBeUsState.h"

static NSString *const kTarget = @"target";
static NSString *const kActionValue = @"actionValue";
//static NSString *const kServiceBaseURL = @"http://www.wherebe.us";

// use this base URL instead for local testing (useful for debugging from simulator!)
static NSString *const kServiceBaseURL = @"http://localhost:8080";


@implementation ConnectionHelper

//------------------------------------------------------------------------
// Helper code to make everything automagical.
//------------------------------------------------------------------------

+ (NSDictionary *)dictionaryFromTarget:(id)target action:(SEL)action
{
	NSValue *actionValue = [NSValue valueWithPointer:action];	
	return [NSDictionary dictionaryWithObjectsAndKeys:target, kTarget, actionValue, kActionValue, nil];		
}

+ (void)expandDictionary:(NSDictionary *)myUserData target:(id *)target action:(SEL *)action
{
	*target = [myUserData objectForKey:kTarget];
	*action = (SEL) [[myUserData objectForKey:kActionValue] pointerValue];
}

+ (id)getDelegate
{
	static ConnectionHelper *_sing;
	
	@synchronized (self)
	{
		if (_sing == nil)
		{
			_sing = [[self alloc] init];
		}		
	}
	
	return _sing;
}

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		facebookRequestToDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		CFRetain(facebookRequestToDictionary);
	}
	return self;
}

- (void)dealloc
{
	CFDictionaryRemoveAllValues(facebookRequestToDictionary);
	CFRelease(facebookRequestToDictionary);
	[super dealloc];
}

- (CFMutableDictionaryRef)facebookRequestToDictionary
{
	return facebookRequestToDictionary;
}


//------------------------------------------------------------------------
// Public API
//------------------------------------------------------------------------

+ (void)twitter_verifyCredentialsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	[[JsonConnection alloc] initWithURL:@"http://twitter.com/account/verify_credentials.json" delegate:[ConnectionHelper getDelegate] userData:d authUsername:username authPassword:password postData:nil];	
}

+ (void)twitter_postTweetWithTarget:(id)target action:(SEL)action message:(NSString *)message username:(NSString *)username password:(NSString *)password
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	NSDictionary *postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:message, @"status", nil];
	[[JsonConnection alloc] initWithURL:@"http://twitter.com/statuses/update.json" delegate:[ConnectionHelper getDelegate] userData:d authUsername:username authPassword:password postData:[postDictionary postData]];
}

+ (void)wbu_updateWithTarget:(id)target action:(SEL)action coordinate:(CLLocationCoordinate2D)coordinate
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	WhereBeUsState *state = [WhereBeUsState shared];	
	
	// Build up information about services...
	NSMutableArray *services = [NSMutableArray arrayWithCapacity:1];
	if (state.hasTwitterCredentials)
	{
		[services addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"facebook", @"service_type",
							 [NSNumber numberWithUnsignedLongLong:state.facebookUserId], @"id_on_service",
							 state.facebookFullName, @"display_name",
							 state.facebookProfileImageURL, @"profile_image_url",
							 state.facebookFriendIds, @"friends",
							 nil]];
	}
	
	if (state.hasFacebookCredentials)
	{
		[services addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							 @"twitter", @"service_type",
							 [NSNumber numberWithUnsignedLongLong:state.twitterUserId], @"id_on_service",
							 state.twitterFullName, @"display_name",
							 state.twitterProfileImageURL, @"profile_image_url",
							 state.twitterFriendIds, @"friends",
							 nil]];
	}
	
	NSString *safeMessage = state.lastMessage;
	if (safeMessage == nil)
	{
		safeMessage = @"";
	}
	
	NSDictionary *postDictionary = 
		[NSDictionary dictionaryWithObjectsAndKeys:
		 services, @"services",
		 [NSNumber numberWithFloat:coordinate.latitude], @"latitude",
		 [NSNumber numberWithFloat:coordinate.longitude], @"longitude",
		 [NSNumber numberWithBool:YES], @"want_updates",
		 safeMessage, @"message",
		 nil];
		
	NSString *postJson = [postDictionary JSONRepresentation];
	[[JsonConnection alloc] initWithURL:[NSString stringWithFormat:@"%@/api/1/update/", kServiceBaseURL] delegate:[ConnectionHelper getDelegate] userData:d authUsername:nil authPassword:nil postData:[postJson dataUsingEncoding:NSUTF8StringEncoding]];		
}

+ (void)fb_requestWithTarget:(id)target action:(SEL)action call:(NSString *)method params:(NSDictionary *)params
{
	FBRequest *request = [FBRequest requestWithDelegate:[ConnectionHelper getDelegate]];
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	CFDictionarySetValue([[ConnectionHelper getDelegate] facebookRequestToDictionary], request, d);
	[request call:method params:params];
}


//------------------------------------------------------------------------
// Json callback
//------------------------------------------------------------------------

- (void)jsonConnection:(JsonConnection *)jsonConnection didReceiveResponse:(JsonResponse*)jsonResponse userData:(id)theUserData
{
	id target;
	SEL action;
	[ConnectionHelper expandDictionary:theUserData target:&target action:&action];
	
	[target performSelector:action withObject:jsonResponse];	
	
	[jsonConnection release];	
}

- (void)jsonConnection:(JsonConnection *)jsonConnection didFailWithError:(NSError *)error userData:(id)theUserData
{
	id target;
	SEL action;
	[ConnectionHelper expandDictionary:theUserData target:&target action:&action];
	
	[target performSelector:action withObject:nil];	
	
	[jsonConnection release];			
}


//------------------------------------------------------------------------
// FBRequestDelegate
//------------------------------------------------------------------------

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	for (id key in [error userInfo])
	{
		NSLog(@"Facebook request error: %@: %@", key, [[error userInfo] objectForKey:key]);
	}
	
	id target;
	SEL action;	
	NSDictionary *d = (NSDictionary *) CFDictionaryGetValue(facebookRequestToDictionary, request);	
	[ConnectionHelper expandDictionary:d target:&target action:&action];
	
	[target performSelector:action withObject:nil];
	CFDictionaryRemoveValue(facebookRequestToDictionary, request);
}

- (void)request:(FBRequest*)request didLoad:(id)result
{
	id target;
	SEL action;	
	NSDictionary *d = (NSDictionary *) CFDictionaryGetValue(facebookRequestToDictionary, request);	
	[ConnectionHelper expandDictionary:d target:&target action:&action];
	
	[target performSelector:action withObject:result];
	CFDictionaryRemoveValue(facebookRequestToDictionary, request);	
}

- (void)requestWasCancelled:(FBRequest*)request
{
	id target;
	SEL action;	
	NSDictionary *d = (NSDictionary *) CFDictionaryGetValue(facebookRequestToDictionary, request);	
	[ConnectionHelper expandDictionary:d target:&target action:&action];
	
	[target performSelector:action withObject:nil];
	CFDictionaryRemoveValue(facebookRequestToDictionary, request);		
}

@end
