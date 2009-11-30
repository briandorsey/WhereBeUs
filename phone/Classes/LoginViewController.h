//
//  LoginViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController {
	IBOutlet UILabel *helpMessage;
	
	IBOutlet UIButton *facebookButton;
	IBOutlet UILabel *facebookStatus;
	IBOutlet UILabel *facebookAccount;
	
	IBOutlet UIButton *twitterButton;
	IBOutlet UILabel *twitterStatus;
	IBOutlet UILabel *twitterAccount;
}

@property (nonatomic, retain) IBOutlet UILabel *helpMessage;

@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UILabel *facebookStatus;
@property (nonatomic, retain) IBOutlet UILabel *facebookAccount;

@property (nonatomic, retain) IBOutlet UIButton *twitterButton;
@property (nonatomic, retain) IBOutlet UILabel *twitterStatus;
@property (nonatomic, retain) IBOutlet UILabel *twitterAccount;

- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;

@end
