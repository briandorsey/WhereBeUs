//
//  TwitterService.m
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "ConnectionHelper.h"
#import "JsonResponse.h"
#import "NSObject+SBJSON.h"

static NSString *const kTarget = @"target";
static NSString *const kActionValue = @"actionValue";


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


//------------------------------------------------------------------------
// Public API
//------------------------------------------------------------------------

+ (void)twitter_verifyCredentialsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	[[JsonConnection alloc] initWithURL:@"http://twitter.com/account/verify_credentials.json" delegate:[ConnectionHelper getDelegate] userData:d authUsername:username authPassword:password postData:nil];	
}

+ (void)ts_getUpdatesForHashtag:(NSString *)hashtag
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	[[JsonConnection alloc] initWithURL:[NSString stringWithFormat:@"http://localhost:8080/api/1/hashtag/%@/", hashtag] delegate:[ConnectionHelper getDelegate] userData:d authUsername:nil authPassword:nil postData:nil];	
}

+ (void)ts_postUpdateWithTwitterUsername:(NSString *)twitterUsername 
						 twitterFullName:(NSString *)twitterFullName 
				  twitterProfileImageURL:(NSString *)twitterProfileImageURL 
								 hashtag:(NSString *)hashtag 
							  coordinate:(CLLocationCoordinate2D)coordinate
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	NSDictionary *postDictionary = [NSDictionary dictionaryWithObjectsAndKeys:twitterUsername, @"twitter_username", twitterFullName, @"twitter_full_name", twitterProfileImageURL, @"twitter_profile_image_url", hashtag, @"hashtag", [NSNumber numberWithFloat:coordinate.latitude], @"latitude", [NSNumber numberWithFloat:coordinate.longitude], @"longitude", nil];
	NSString *postJson = [postDictionary JSONRepresentation];
	[[JsonConnection alloc] initWithURL:[NSString stringWithFormat:@"http://localhost:8080/api/1/hashtag/%@/", hashtag] delegate:[ConnectionHelper getDelegate] userData:d authUsername:nil authPassword:nil postData:postJson];		
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


@end
