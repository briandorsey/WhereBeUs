//
//  TweetViewController.m
//  WhereBeUs
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "SendMessageViewController.h"
#import "WhereBeUsState.h"
#import "Utilities.h"
#import "WhereBeUsAppDelegate.h"
#import "ConnectionHelper.h"
#import "JsonResponse.h"


@implementation SendMessageViewController

@synthesize messageText;
@synthesize activityIndicator;


//---------------------------------------------------------------
// Set Up / Tear Down
//---------------------------------------------------------------

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle customMessage:(NSString *)theCustomMessage
{
	self = [super initWithNibName:nibName bundle:nibBundle];
    if (self != nil) 
	{
		customMessage = [theCustomMessage retain];
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
	WhereBeUsState *state = [WhereBeUsState shared];
	if (customMessage != nil)
	{
		[self.messageText setText:customMessage];
	}
	else
	{
		if (!state.hasEverSentMessage)
		{							 
			[self.messageText setText:@"I'm going places! Follow me with http://wherebe.us/"];
		}
		else
		{
			[self.messageText setText:@""];
		}
	}
	
	[self.messageText becomeFirstResponder];
	[self.activityIndicator stopAnimating];
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)dealloc 
{
	[customMessage release];
	self.messageText = nil;
	self.activityIndicator = nil;
    [super dealloc];
}


//---------------------------------------------------------------
// Actions
//---------------------------------------------------------------

- (IBAction)cancelButtonPushed:(id)sender
{
	[self.activityIndicator stopAnimating];
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *)[UIApplication sharedApplication].delegate;
	[[appDelegate frontSideNavigationController] hideModalSendMessage];
}


//---------------------------------------------------------------
// Posting
//---------------------------------------------------------------

- (void)doneWithDialog
{
	[self.activityIndicator stopAnimating];
	WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) [UIApplication sharedApplication].delegate;
	[[appDelegate frontSideNavigationController] hideModalSendMessage];		
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.messageText becomeFirstResponder];
}

- (void)failedDialogWithTitle:(NSString *)title message:(NSString *)message
{
	[self.activityIndicator stopAnimating];
	[Utilities displayModalAlertWithTitle:title message:message buttonTitle:@"OK" delegate:self];
}

- (void)doneSendingMessageToFacebook:(id)result
{
	if ((result == nil) || (![result isKindOfClass:[NSString class]]) || (![result isEqualToString:@"1"]))
	{
		[self failedDialogWithTitle:@"Facebook Failure" message:@"Couldn't post to Facebook. Please try again."];
		return;
	}

	[self doneWithDialog];
}

- (void)sendMessageToFacebook:(NSString *)message
{
	WhereBeUsState *state = [WhereBeUsState shared];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%qu", state.facebookUserId], @"uid", message, @"status", nil];
	[ConnectionHelper fb_requestWithTarget:self action:@selector(doneSendingMessageToFacebook:) call:@"facebook.status.set" params:params];
}

- (void)dialogDidSucceed:(FBDialog*)dialog 
{
	// This method is an FBDialogDelegate callback
	WhereBeUsState *state = [WhereBeUsState shared];
	[state setHasFacebookStatusUpdatePermission:YES];
	[state save];	
	[self sendMessageToFacebook:state.lastMessage];
}

- (void)dialogDidCancel:(FBDialog *)dialog
{
	[self failedDialogWithTitle:@"Facebook Failure" message:@"Couldn't post to Facebook because permission was denied. Please try again."];
}

- (void)askForFacebookStatusUpdatePermission
{
	FBPermissionDialog* dialog = [[[FBPermissionDialog alloc] init] autorelease];
	dialog.delegate = self;
	dialog.permission = @"status_update";
	[dialog show];
}

- (void)prepareToSendMessageToFacebook:(NSString *)message
{
	WhereBeUsState *state = [WhereBeUsState shared];
	if (state.hasFacebookStatusUpdatePermission)
	{
		[self sendMessageToFacebook:message];
	}
	else
	{
		[self askForFacebookStatusUpdatePermission];
	}
}

- (void)doneSendingMessageToTwitter:(JsonResponse *)response
{
	// did we fail? Bail, but stay with this view.
	if (response == nil)
	{
		[self failedDialogWithTitle:@"Twitter Failure" message:@"Couldn't post your tweet. Please try again."];
		return;
	}	

	WhereBeUsState *state = [WhereBeUsState shared];
	if (state.hasFacebookCredentials)
	{
		[self prepareToSendMessageToFacebook:state.lastMessage];
	}
	else
	{	
		[self doneWithDialog];
	}
}

- (void)sendMessageToTwitterThenIfNecessaryToFacebook:(NSString *)message
{
	// send the message!
	WhereBeUsState *state = [WhereBeUsState shared];
	[ConnectionHelper twitter_postTweetWithTarget:self action:@selector(doneSendingMessageToTwitter:) message:message username:state.twitterUsername password:state.twitterPassword];
}

- (void)sendMessage
{
	// Action!
	[self.activityIndicator startAnimating];
	
	// get and store the message
	WhereBeUsState *state = [WhereBeUsState shared];
	state.lastMessage = [self.messageText text];
	[state save];
	
	// start by sending the message to twitter...
	if (state.hasTwitterCredentials)
	{
		[self sendMessageToTwitterThenIfNecessaryToFacebook:state.lastMessage];
	}
	else if (state.hasFacebookCredentials)
	{
		[self prepareToSendMessageToFacebook:state.lastMessage];
	}
}


//---------------------------------------------------------------
// Text View Delegate
//---------------------------------------------------------------

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
	if ([text isEqualToString:@"\n"]) 
	{
		// The "send" button was pressed! -- yes, this is really how to do it with a UITextVIEW (not UITextField)
		[textView resignFirstResponder];
		[self sendMessage];
		return NO;
	}
	
	// make sure the edited text won't be too long.
	// XXX TODO real interface/feedback for this
	if ([[textView.text stringByReplacingCharactersInRange:range withString:text] length] > 140)
	{
		return NO;
	}
	
	return YES;
}


@end
