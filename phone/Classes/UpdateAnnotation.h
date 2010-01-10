//
//  UpdateAnnotation.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface UpdateAnnotation : NSObject<MKAnnotation> {
	NSString *displayName;
	NSString *profileImageURL;
	NSString *largeProfileImageURL;
	NSString *message;
	NSString *serviceType;
	NSString *serviceURL;
	NSDate *lastUpdate;
	NSDate *lastMessageUpdate;
	CLLocationCoordinate2D coordinate;
	
	BOOL visited;	
	NSString *title;	
}

+ (id)updateAnnotationWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

- (NSString *)title;
- (NSString *)subtitle;
- (void)setLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;

@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *profileImageURL;
@property (nonatomic, retain) NSString *largeProfileImageURL;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *serviceType;
@property (nonatomic, retain) NSString *serviceURL;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSDate *lastMessageUpdate;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property BOOL visited;

@end
