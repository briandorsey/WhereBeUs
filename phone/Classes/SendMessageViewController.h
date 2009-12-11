//
//  TweetViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SendMessageViewController : UIViewController<UITextViewDelegate> {
	IBOutlet UITextView *messageText;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	BOOL sendingToFacebook;
	BOOL sendingToTwitter;
	
}

@property (nonatomic, retain) IBOutlet UITextView *messageText;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)cancelButtonPushed:(id)sender;

@end
