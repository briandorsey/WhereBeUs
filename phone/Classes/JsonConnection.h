//
//  JsonConnection.h
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSString+URLEncode.h"

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
+ (id)connectionWithURL:(NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData authUsername:(NSString *)theAuthUsername authPassword:(NSString *)theAuthPassword;

+ (id)postConnectionWithURL:(NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData postData:(NSData *)postData;

- (id)initWithURL: (NSString *)theURL delegate:(id<JsonConnectionDelegate>)theDelegate userData:(id)theUserData authUsername:(NSString *)theAuthUsername authPassword:(NSString *)theAuthPassword postData:(NSData *)thePostData;
- (void)cancel;

@end

@protocol JsonConnectionDelegate<NSObject>
- (void)jsonConnection:(JsonConnection *)jsonConnection didReceiveResponse:(JsonResponse*)jsonResponse userData:(id)theUserData;
- (void)jsonConnection:(JsonConnection *)jsonConnection didFailWithError:(NSError *)error userData:(id)theUserData;
@end


