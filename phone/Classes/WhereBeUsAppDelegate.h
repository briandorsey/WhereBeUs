//
//  WhereBeUsAppDelegate.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "WhereBeUsWindow.h"
#import "TwitterCredentialsViewController.h"
#import "FBConnect/FBConnect.h"

#define FACEBOOK_CREDENTIALS_CHANGED @"wherebeus_facebook_credentials_changed"
#define TWITTER_CREDENTIALS_CHANGED @"wherebeus_twitter_credentials_changed"

@interface WhereBeUsAppDelegate : NSObject <UIApplicationDelegate, TwitterCredentialsViewControllerDelegate, FBSessionDelegate> {    
    WhereBeUsWindow *window;
    UINavigationController *navigationController;
	FBSession *facebookSession;
	UINavigationBar *bar;
}

@property (nonatomic, retain) IBOutlet WhereBeUsWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void)showMapViewController:(BOOL)animated;
- (void)showModalTweetViewController;
- (void)popViewController:(BOOL)animated;
- (void)showTwitterCredentialsController;

- (FBSession *)facebookSession;
- (void)notifyFacebookCredentialsChanged;
- (void)notifyTwitterCredentialsChanged;

@end




