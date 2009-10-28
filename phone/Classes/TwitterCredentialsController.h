//
//  TwitterCredentialsController.h
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TwitterCredentialsController : UIViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *loginButton;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonPushed:(id)sender;
- (IBAction)textChanged:(id)sender;

@end
