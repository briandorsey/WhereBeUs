//
//  UpdateDetailsViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 1/7/10.
//  Copyright 2010 Code Orange. All rights reserved.
//

#import "UpdateDetailsViewController.h"
#import "WhereBeUsAppDelegate.h"
#import "NSDate+PrettyPrint.h"

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


- (BOOL)hasAnnotationMessage
{
	return annotation.message.length > 0;
}

- (NSString *)annotationMessage
{
	if (annotation.message.length > 0)
	{
		return annotation.message;
	}
	return [NSString stringWithFormat:@"(no message from %@)", annotation.displayName];
}


//--------------------------------------------------------------------------------
// UITableViewDelegate
//--------------------------------------------------------------------------------

const NSInteger kMessageSection = 1;
const NSInteger kLocationSection = 2;
const NSInteger kServiceSection = 3;
const CGFloat kEmpiricallyDeterminedCellContentWidth = 300.0;
const CGFloat kEmpiricallyDeterminedCellMinimumHeight = 43.0;
const CGFloat kEmpiricallyDeterminedHeightMargin = 13.5;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = kEmpiricallyDeterminedCellMinimumHeight;	
	NSUInteger section = [indexPath indexAtPosition:0];
	NSUInteger row = [indexPath indexAtPosition:1];
	
	if (section == kMessageSection)
	{
		if (row == 0)
		{
			NSString *annotationMessage = [self annotationMessage];
			CGSize size = [annotationMessage sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(kEmpiricallyDeterminedCellContentWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			height = size.height + (kEmpiricallyDeterminedHeightMargin * 2.0);			
		}
	}
	
	if (height < kEmpiricallyDeterminedCellMinimumHeight)
	{
		height = kEmpiricallyDeterminedCellMinimumHeight;
	}			
	
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	NSUInteger section = [indexPath indexAtPosition:0];
//	
//	if (section == kMessageSection)
//	{
//		UITableViewCell *cell = (UITableViewCell *) [tableView cellForRowAtIndexPath: indexPath];
//		UIView *contentView = [cell contentView];
//		CGRect bounds = contentView.bounds;
//
//		NSLog(@"Origin x: %f", bounds.origin.x);
//		NSLog(@"Origin y: %f", bounds.origin.y);
//		NSLog(@"Size width: %f", bounds.size.width);
//		NSLog(@"Size height: %f", bounds.size.height);
//	}
}


//--------------------------------------------------------------------------------
// UITableViewDataSource
//--------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kServiceSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath indexAtPosition:0];
	NSUInteger row = [indexPath indexAtPosition:1];

	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];	

	if (section == kMessageSection)
	{	
		if (row == 0)
		{
			cell.textLabel.text = [self annotationMessage];
			cell.textLabel.numberOfLines = 0;
			cell.textLabel.font = [UIFont systemFontOfSize:13.0];
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		}
		else if (row == 1)
		{
			NSString *interval = [[NSDate date] prettyPrintTimeIntervalSinceDate:annotation.lastMessageUpdate];
			cell.textLabel.text = [NSString stringWithFormat:@"(message written %@)", interval];
			cell.textLabel.font = [UIFont systemFontOfSize:13.0];
			cell.textLabel.textColor = [UIColor grayColor];
		}
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kMessageSection)
	{
		return [self hasAnnotationMessage] ? 2 : 1;
	}
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
		self.displayNameView.shadowColor = [UIColor whiteColor];
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
