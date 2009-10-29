//
//  AsyncImageView.h
//  TweetSpot
//
//  Created by markj on 2/18/09.
//  Copyright 2009 Mark Johnson. You have permission to copy parts of this code into your own projects for any use.
//  www.markj.net
//

#import <UIKit/UIKit.h>

@protocol AsyncImageViewDelegate;

@interface AsyncImageView : UIView {
	NSURLConnection* connection; 
	NSMutableData* data; 
	id<AsyncImageViewDelegate> delegate;
}

@property (nonatomic, assign) id<AsyncImageViewDelegate> delegate;

- (void)loadImageFromURL:(NSURL *)url;
- (void)clearImage;
- (UIImage *)image;
- (void)setImage:(UIImage *)newImage;

@end

@protocol AsyncImageViewDelegate <NSObject>
- (void)asyncImageView:(AsyncImageView *)aiv didFinishLoadingImage:(BOOL)success;
@end
