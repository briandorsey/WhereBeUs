//
//  UpdateAnnotation.h
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UpdateAnnotation : NSObject<MKAnnotation> {
	NSString *twitterUsername;
	NSString *twitterFullName;
	NSURL *twitterProfileImageURL;
	NSString *message;
	NSDate *lastUpdate;
	CLLocationCoordinate2D coordinate;	
	
	BOOL visited;
	
	NSString *title;	
}

+ (id)updateAnnotationWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

- (NSString *)title;
- (NSString *)subtitle;

@property (nonatomic, retain) NSString *twitterUsername;
@property (nonatomic, retain) NSString *twitterFullName;
@property (nonatomic, retain) NSURL *twitterProfileImageURL;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property BOOL visited;

@end
