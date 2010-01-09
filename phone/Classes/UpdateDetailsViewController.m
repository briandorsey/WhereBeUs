//
//  UpdateDetailsViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/7/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "UpdateDetailsViewController.h"
#import "WhereBeUsAppDelegate.h"


@implementation UpdateDetailsViewController

@synthesize profileImageView;
@synthesize displayNameView;
@synthesize infoTableView;

//---------------------------------------------------------------------
// Static methods for accessing frequently-used images
//---------------------------------------------------------------------

+ (UIImage *)defaultUserImage
{
	static UIImage *_defaultUserImage;
	
	@synchronized (self)
	{
		if (_defaultUserImage == nil)
		{
			_defaultUserImage = [[UIImage imageNamed:@"default100.png"] retain];
		}		
	}
	
	return _defaultUserImage;
}


//--------------------------------------------------------------------------------
// UITableViewDelegate
//--------------------------------------------------------------------------------


//--------------------------------------------------------------------------------
// UITableViewDataSource
//--------------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}


//--------------------------------------------------------------------------------
// Overrides, etc.
//--------------------------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil annotation:(UpdateAnnotation *)theAnnotation
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) 
	{
		annotation = [theAnnotation retain];
		self.title = @"User Details";
    }
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate frontSideNavigationController] setNavigationBarHidden:NO animated:YES];		
	
	if (annotation != nil)
	{
		self.displayNameView.text = annotation.displayName;
		if (annotation.largeProfileImageURL != nil)
		{
			[self.profileImageView setDefaultImage:[UpdateDetailsViewController defaultUserImage] urlToLoad:annotation.largeProfileImageURL alternateUrlToLoad:annotation.profileImageURL];			
		}
		else
		{
			[self.profileImageView setDefaultImage:[UpdateDetailsViewController defaultUserImage] urlToLoad:annotation.profileImageURL alternateUrlToLoad:annotation.profileImageURL];
		}
	}
	
	[super viewWillAppear:animated];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate frontSideNavigationController] setNavigationBarHidden:YES animated:animated];	
	[super viewWillDisappear:animated];
}

- (void)dealloc 
{
	[annotation release];
    [super dealloc];
}

@end
