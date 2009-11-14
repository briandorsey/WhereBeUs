//
//  WhereBeUsAppDelegate.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "WhereBeUsWindow.h"
#import "TwitterCredentialsViewController.h"

@interface WhereBeUsAppDelegate : NSObject <UIApplicationDelegate, TwitterCredentialsViewControllerDelegate> {    
    WhereBeUsWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet WhereBeUsWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void)showMapViewController:(BOOL)animated;
- (void)showTweetViewController:(BOOL)animated;
- (void)popViewController:(BOOL)animated;

@end

