//
//  AsyncImageCache.h
//  TweetSpot
//
//  Created by Dave Peck on 11/5/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AsyncImageCacheDelegate;

@interface AsyncImageCache : NSObject {
	NSMutableDictionary *urlToImage;
	
	/* we use a CFMutableDictionary rather than an NSMutableDictionary because, unfortunately,
	   NSMutableDictionary copies its keys -- and since we want to use NSURLConnection as a key,
	   that won't work for us. On the other hand, CFMutableDictionary merely retains its keys. */
	CFMutableDictionaryRef connectionToDictionary;
}

+ (AsyncImageCache *)shared;

- (UIImage *)imageForURL:(NSString *)url;
- (void)loadImageForURL:(NSString *)url delegate:(id<AsyncImageCacheDelegate>)delegate;
- (void)clearImageForURL:(NSString *)url;
- (void)clearAllImages;

@end

@protocol AsyncImageCacheDelegate<NSObject>

- (void)asyncImageCacheLoadedImage:(UIImage *)image forURL:(NSString *)url;

@end