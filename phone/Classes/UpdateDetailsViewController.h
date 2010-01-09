//
//  UpdateDetailsViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 1/7/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateAnnotation.h"


@interface UpdateDetailsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UIImageView *profileImageView;
	IBOutlet UILabel *displayNameView;
	IBOutlet UITableView *infoTableView;
	
	UpdateAnnotation *annotation;
}

@property (nonatomic, retain) UIImageView *profileImageView;
@property (nonatomic, retain) UILabel *displayNameView;
@property (nonatomic, retain) UITableView *infoTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil annotation:(UpdateAnnotation *)annotation;

@end
