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
#import "MKPlacemark+PrettyPrint.h"

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

const NSInteger kMessageSection = 0;
const NSInteger kLocationSection = 1;
const NSInteger kServiceSection = 2;
//const CGFloat kEmpiricallyDeterminedCellContentWidth = 300.0;
//const CGFloat kEmpiricallyDeterminedCellMinimumHeight = 43.0;
//const CGFloat kEmpiricallyDeterminedHeightMargin = 13.5;
const CGFloat kEmpiricallyDeterminedCellContentWidth = 207.0;
const CGFloat kEmpiricallyDeterminedCellMinimumHeight = 43.0;
const CGFloat kEmpiricallyDeterminedHeightMargin = 13.5;

- (NSIndexPath *)tableView:(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath indexAtPosition:0];	
	return (section == kServiceSection) ? indexPath : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = kEmpiricallyDeterminedCellMinimumHeight;	
	NSUInteger section = [indexPath indexAtPosition:0];
	
	if (section == kMessageSection)
	{
		NSString *annotationMessage = [self annotationMessage];
		CGSize size = [annotationMessage sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(kEmpiricallyDeterminedCellContentWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		height = size.height + (kEmpiricallyDeterminedHeightMargin * 2.0);			
	}
	else if (section == kLocationSection)
	{
		NSString *locationMessage = friendlyLocation;
		if (locationMessage == nil)
		{
			locationMessage = @"(acquiring location)";
		}
		CGSize size = [locationMessage sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(kEmpiricallyDeterminedCellContentWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		height = size.height + (kEmpiricallyDeterminedHeightMargin * 2.0);					
	}
	
	if (height < kEmpiricallyDeterminedCellMinimumHeight)
	{
		height = kEmpiricallyDeterminedCellMinimumHeight;
	}			
	
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath indexAtPosition:0];
	
	if (section == kServiceSection)
	{
		NSUInteger row = [indexPath indexAtPosition:1];
		if (row == 0)
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:annotation.serviceURL]];
		}
		else
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@", annotation.idOnService]]];
		}
	}
}


//--------------------------------------------------------------------------------
// UITableViewDataSource
//--------------------------------------------------------------------------------


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kServiceSection + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath indexAtPosition:0];

	UITableViewCell *cell = nil;

	if (section == kMessageSection)
	{	
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"message"] autorelease];	
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"message";		
		cell.detailTextLabel.text = [self annotationMessage];
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
	}
	else if (section == kLocationSection)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"location"] autorelease];	
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"location";
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
		
		if (friendlyLocation != nil)
		{
			cell.detailTextLabel.text = friendlyLocation;
		}
		else
		{
			cell.detailTextLabel.text = @"(acquiring location)";
		}
	}
	else if (section == kServiceSection)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"service"] autorelease];	
		if (annotation.isTwitter)
		{
			cell.textLabel.text = [NSString stringWithFormat:@"Visit %@ on Twitter", annotation.displayName];
		}
		else
		{
			NSUInteger row = [indexPath indexAtPosition:1];
			if (row == 0)
			{
				cell.textLabel.text = [NSString stringWithFormat:@"Visit %@ on Facebook Site", annotation.displayName];
			}
			else
			{
				cell.textLabel.text = [NSString stringWithFormat:@"Visit %@ in Facebook App", annotation.displayName];
			}
		}
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.textColor = [UIColor colorWithRed:0.322 green:0.4 blue:0.569 alpha:1.0];
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == kServiceSection && annotation.isFacebook)
	{
		return 2;
	}
	return 1;
}


//--------------------------------------------------------------------------------
// MKReverseGeocoder Delegate
//--------------------------------------------------------------------------------

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	friendlyLocation = [[placemark prettyPrint] retain];
	[self.infoTableView reloadData];	
	[reverseGeocoder release];
	reverseGeocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"Geocoder error: %@", [error localizedDescription]);
	friendlyLocation = [[NSString stringWithString:@"(unable to get address)"] retain];
	[self.infoTableView reloadData];
	[reverseGeocoder release];
	reverseGeocoder = nil;
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
		
		if (reverseGeocoder != nil)
		{
			[reverseGeocoder cancel];
			[reverseGeocoder release];
		}
		
		if (friendlyLocation != nil)
		{
			[friendlyLocation release];
			friendlyLocation = nil;
		}
		
		reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:annotation.coordinate];
		reverseGeocoder.delegate = self;
		[reverseGeocoder start];
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
	if (reverseGeocoder != nil)
	{
		[reverseGeocoder cancel];
		[reverseGeocoder release];
	}
	if (friendlyLocation != nil)
	{
		[friendlyLocation release];
	}
	
    [super dealloc];
}

@end
