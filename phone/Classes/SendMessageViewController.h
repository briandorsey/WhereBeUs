//
//  TweetViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"

@interface SendMessageViewController : UIViewController<UITextViewDelegate, FBDialogDelegate, UIAlertViewDelegate> {
	IBOutlet UITextView *messageText;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) IBOutlet UITextView *messageText;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)cancelButtonPushed:(id)sender;

@end
