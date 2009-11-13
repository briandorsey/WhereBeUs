//
//  WhereBeUsAppDelegate.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "WhereBeUsWindow.h"

@protocol WhereBeUsHashtagChangedDelegate;

@interface WhereBeUsAppDelegate : NSObject <UIApplicationDelegate> {    
    WhereBeUsWindow *window;
    UINavigationController *navigationController;
	id<WhereBeUsHashtagChangedDelegate> hashtagDelegate;
}

@property (nonatomic, retain) IBOutlet WhereBeUsWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void)showMapViewController:(BOOL)animated;
- (void)showTweetViewController:(BOOL)animated;
- (void)popViewController:(BOOL)animated;
- (void)setHashtagDelegate:(id<WhereBeUsHashtagChangedDelegate>)newHashtagDelegate;

@end

@protocol WhereBeUsHashtagChangedDelegate<NSObject>
- (void)gotNewHashtag:(NSString *)newHashtag;
@end
