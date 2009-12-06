//
//  LoginViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 11/29/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect/FBConnect.h"


@interface LoginViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, FBSessionDelegate, FBRequestDelegate> {
	IBOutlet UITableView *tableView;
	IBOutlet UIBarButtonItem *doneButton;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

- (void)doneButtonPressed:(id)sender;

@end
