//
//  TweetSpotAppDelegate.h
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "TweetSpotWindow.h"

@protocol TweetSpotHashtagChangedDelegate;

@interface TweetSpotAppDelegate : NSObject <UIApplicationDelegate> {    
    TweetSpotWindow *window;
    UINavigationController *navigationController;
	id<TweetSpotHashtagChangedDelegate> hashtagDelegate;
}

@property (nonatomic, retain) IBOutlet TweetSpotWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void)showMapViewController:(BOOL)animated;
- (void)showTweetViewController:(BOOL)animated;
- (void)popViewController:(BOOL)animated;
- (void)setHashtagDelegate:(id<TweetSpotHashtagChangedDelegate>)newHashtagDelegate;

@end

@protocol TweetSpotHashtagChangedDelegate<NSObject>
- (void)gotNewHashtag:(NSString *)newHashtag;
@end
