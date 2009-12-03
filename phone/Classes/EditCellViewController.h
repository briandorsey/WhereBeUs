//
//  EditCellViewController.h
//  WhereBeUs
//
//  Created by Dave Peck on 12/2/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditCellViewController : UIViewController {
	IBOutlet UILabel *label;
	IBOutlet UITextField *textField;
	
	NSString *labelText;
	NSString *textFieldPlaceholder;	
	BOOL clearsOnBeginEditing;
	UITextAutocorrectionType autocorrectionType;
	BOOL enablesReturnKeyAutomatically;
	UIReturnKeyType returnKeyType;
	BOOL secureTextEntry;
	id<UITextFieldDelegate> textFieldDelegate;	
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) NSString *labelText;
@property (nonatomic, retain) NSString *textFieldPlaceholder;
@property BOOL clearsOnBeginEditing;
@property UITextAutocorrectionType autocorrectionType;
@property BOOL enablesReturnKeyAutomatically;
@property UIReturnKeyType returnKeyType;
@property BOOL secureTextEntry;
@property (nonatomic, assign) id<UITextFieldDelegate> textFieldDelegate;

- (UITableViewCell *)cell;

@end
