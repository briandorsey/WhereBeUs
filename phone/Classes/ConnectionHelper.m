//
//  TwitterService.m
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "ConnectionHelper.h"
#import "JsonResponse.h"

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

+ (void)verifyCredentialsWithTarget:(id)target action:(SEL)action username:(NSString *)username password:(NSString *)password
{
	NSDictionary *d = [ConnectionHelper dictionaryFromTarget:target action:action];
	[[JsonConnection alloc] initWithURL:@"http://twitter.com/account/verify_credentials.json" delegate:[ConnectionHelper getDelegate] userData:d authUsername:username authPassword:password];	
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
