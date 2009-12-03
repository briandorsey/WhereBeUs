//
//  EditCellViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 12/2/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "EditCellViewController.h"


@implementation EditCellViewController

@synthesize label;
@synthesize textField;

@synthesize labelText;
@synthesize textFieldPlaceholder;
@synthesize clearsOnBeginEditing;
@synthesize autocorrectionType;
@synthesize enablesReturnKeyAutomatically;
@synthesize returnKeyType;
@synthesize secureTextEntry;
@synthesize textFieldDelegate;


- (UITableViewCell*)cell
{
	return (UITableViewCell *)self.view;
}

- (void)viewDidLoad
{
	self.label.text = self.labelText;
	self.textField.placeholder = self.textFieldPlaceholder;
	
	self.textField.clearsOnBeginEditing = self.clearsOnBeginEditing;
	self.textField.autocorrectionType = self.autocorrectionType;
	self.textField.enablesReturnKeyAutomatically = self.enablesReturnKeyAutomatically;
	self.textField.returnKeyType = self.returnKeyType;
	self.textField.secureTextEntry = self.secureTextEntry;
	self.textField.delegate = self.textFieldDelegate;	
}

- (void)dealloc 
{
	self.label = nil;
	self.textField = nil;	
	
	self.labelText = nil;
	self.textFieldPlaceholder = nil;
	self.textFieldDelegate = nil;
	
    [super dealloc];
}


@end
