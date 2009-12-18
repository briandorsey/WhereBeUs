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
static NSString *const kServiceBaseURL = @"http://www.wherebe.us";

// use this base URL instead for local testing (useful for debugging from simulator!)
// static NSString *const kServiceBaseURL = @"http://localhost:8080";


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

+ (void)twitter_getFriendsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	[[JsonConnection alloc] initWithURL:[NSString stringWithFormat:@"http://twitter.com/friends/ids/%@.json", username]
							   delegate:[ConnectionHelper getDelegate] 
							   userData:d 
						   authUsername:username 
						   authPassword:password
							   postData:nil];
}

+ (void)wbu_updateWithTarget:(id)target action:(SEL)action coordinate:(CLLocationCoordinate2D)coordinate
{
	// Hold onto information about what we've communicated to the service previously --
	// this can substantially reduce the size of our network communications.
	// We don't do deep equality tests -- reference tests are fine.
	static NSString *previousFacebookDisplayName = nil;
	static NSString *previousFacebookProfileImageURL = nil;
	static NSArray *previousFacebookFriendIds = nil;
	static NSString *previousTwitterDisplayName = nil;
	static NSString *previousTwitterProfileImageURL = nil;
	static NSArray *previousTwitterFriendIds = nil;
	static NSString *previousMessage = nil;

	// Prepare to sync with service
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	WhereBeUsState *state = [WhereBeUsState shared];
	NSMutableArray *services = [NSMutableArray arrayWithCapacity:1];
		
	// Build up information about the facebook service
	if (state.hasFacebookCredentials)
	{
		NSMutableDictionary *facebookService = [NSMutableDictionary dictionaryWithObjectsAndKeys:							 
												@"facebook", @"service_type",
												[NSNumber numberWithUnsignedLongLong:state.facebookUserId], @"id_on_service",
												nil];
		
		if (state.facebookDisplayName != previousFacebookDisplayName)
		{
			[facebookService setObject:state.facebookDisplayName forKey:@"display_name"];
			previousFacebookDisplayName = state.facebookDisplayName;
		}
		
		if (state.facebookProfileImageURL != previousFacebookProfileImageURL)
		{
			[facebookService setObject:state.facebookProfileImageURL forKey:@"profile_image_url"];
			previousFacebookProfileImageURL = state.facebookProfileImageURL;
		}
		
		if (state.facebookFriendIds != previousFacebookFriendIds)
		{
			[facebookService setObject:state.facebookFriendIds forKey:@"friends"];
			previousFacebookFriendIds = state.facebookFriendIds;
		}
		
		[services addObject:[NSDictionary dictionaryWithDictionary:facebookService]];
	}
		
	// Build up information about the twitter service
	if (state.hasTwitterCredentials)
	{
		NSMutableDictionary *twitterService = [NSMutableDictionary dictionaryWithObjectsAndKeys:							 
												@"twitter", @"service_type",
												[NSNumber numberWithUnsignedLongLong:state.twitterUserId], @"id_on_service",
												nil];
		
		if (state.twitterDisplayName != previousTwitterDisplayName)
		{
			[twitterService setObject:state.twitterDisplayName forKey:@"display_name"];
			previousTwitterDisplayName = state.twitterDisplayName;
		}
		
		if (state.twitterProfileImageURL != previousTwitterProfileImageURL)
		{
			[twitterService setObject:state.twitterProfileImageURL forKey:@"profile_image_url"];
			previousTwitterProfileImageURL = state.twitterProfileImageURL;
		}
		
		if (state.twitterFriendIds != previousTwitterFriendIds)
		{
			[twitterService setObject:state.twitterFriendIds forKey:@"friends"];
			previousTwitterFriendIds = state.twitterFriendIds;
		}
		
		[services addObject:[NSDictionary dictionaryWithDictionary:twitterService]];
	}
		
	// What "message" is current?
	NSString *safeMessage = state.lastMessage;
	if (safeMessage == nil)
	{
		safeMessage = @"";
	}

	// Build final information to send to service
	NSMutableDictionary *postDictionary = 
	[NSMutableDictionary dictionaryWithObjectsAndKeys:
	 services, @"services",
	 [NSNumber numberWithFloat:coordinate.latitude], @"latitude",
	 [NSNumber numberWithFloat:coordinate.longitude], @"longitude",
	 [NSNumber numberWithBool:YES], @"want_updates",
	 nil];
	
	if (safeMessage != previousMessage)
	{
		[postDictionary setObject:safeMessage forKey:@"message"];
		previousMessage = safeMessage;
	}

	// Kick off the network request
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
