//
//  LoginViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"


@interface LoginViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *tableView;
	IBOutlet UIBarButtonItem *doneButton;
	
	NSTimer *facebookTimer;
	NSTimer *twitterTimer;
	BOOL facebookActivity;
	BOOL twitterActivity;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (void)doneButtonPressed:(id)sender;

@end
