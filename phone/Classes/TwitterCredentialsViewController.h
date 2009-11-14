//
//  TwitterCredentialsController.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TwitterCredentialsViewControllerDelegate;

@interface TwitterCredentialsViewController : UIViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *loginButton;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	id<TwitterCredentialsViewControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) id<TwitterCredentialsViewControllerDelegate> delegate;

- (IBAction)loginButtonPushed:(id)sender;
- (IBAction)textChanged:(id)sender;

@end


@protocol TwitterCredentialsViewControllerDelegate<NSObject>
- (void)twitterCredentialsViewControllerDidFinish:(TwitterCredentialsViewController *)controller;
@end