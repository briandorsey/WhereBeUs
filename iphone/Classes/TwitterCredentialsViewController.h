//
//  TwitterCredentialsController.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditCellViewController.h"

@protocol TwitterCredentialsViewControllerDelegate;

@interface TwitterCredentialsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
	IBOutlet UITableView *tableView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	id<TwitterCredentialsViewControllerDelegate> delegate;
	
	EditCellViewController *usernameController;
	EditCellViewController *passwordController;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) id<TwitterCredentialsViewControllerDelegate> delegate;

@end


@protocol TwitterCredentialsViewControllerDelegate<NSObject>
- (void)twitterCredentialsViewControllerDidFinish:(TwitterCredentialsViewController *)controller;
@end