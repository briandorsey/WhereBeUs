//
//  SettingsNavigationController.h
//  WhereBeUs
//
//  Created by Dave Peck on 12/8/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterCredentialsViewController.h"

// the SettingsNavigationController manages the entire "back side" 
// view where the user can log in/out, and (possibly in the future)
// choose other non-account-related settings.

@interface BackSideNavigationController : UINavigationController<TwitterCredentialsViewControllerDelegate> {
}

- (void)showTwitterCredentialsController;

@end
