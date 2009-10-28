//
//  JsonConnection.h
//  WalkScore
//
//  Created by Rob LaRubbio on 3/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

enum
{
	JsonConnectionError_Invalid_Json = 1,
	JsonConnectionError_Network_Failure,
	JsonConnectionError_Unknown_Error
} JsonConnectionError;

@protocol JsonConnectionDelegate;
@class JsonResponse;

@interface JsonConnection : NSObject {
    NSURLConnection *connection;
	NSURLResponse *response;
    NSMutableData *data;	
	id<JsonConnectionDelegate> delegate;	
	id userData;	
}

+ (id)connectionWithURL:(NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData;
- (id)initWithURL: (NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData;
- (void)cancel;

@end

@protocol JsonConnectionDelegate<NSObject>
- (void)jsonConnection:(JsonConnection *)jsonConnection didReceiveResponse:(JsonResponse*)jsonResponse userData:(id)theUserData;
- (void)jsonConnection:(JsonConnection *)jsonConnection didFailWithError:(NSError *)error userData:(id)theUserData;
@end


