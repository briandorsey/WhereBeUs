//
//  TweetViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TweetViewController : UIViewController<UITextViewDelegate> {
	IBOutlet UITextView *messageText;
}

@property (nonatomic, retain) IBOutlet UITextView *messageText;


@end
