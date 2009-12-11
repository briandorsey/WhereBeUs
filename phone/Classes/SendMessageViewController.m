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

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle 
{
	self = [super initWithNibName:nibName bundle:nibBundle];
    if (self != nil) 
	{
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[self.messageText setText:@"I'm on the move! Follow me with http://wherebe.us/"];
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

- (void)doneSendingMessage
{
	if (!sendingToTwitter && !sendingToFacebook)
	{
		[self.activityIndicator stopAnimating];
		
		// All done; go back to the map view.
		WhereBeUsAppDelegate *appDelegate = (WhereBeUsAppDelegate *) [UIApplication sharedApplication].delegate;
		[[appDelegate frontSideNavigationController] hideModalSendMessage];		
	}
}

- (void)doneSendingMessageToTwitter:(JsonResponse *)response
{
	if (response == nil)
	{
		[Utilities displayModalAlertWithTitle:@"Twitter Failure" message:@"Couldn't post your tweet. Please try again." buttonTitle:@"OK" delegate:nil];
	}
	
	// done; clean up
	sendingToTwitter = NO;
	[self doneSendingMessage];
}

- (void)sendMessageToTwitter:(NSString *)message
{
	// send the message!
	WhereBeUsState *state = [WhereBeUsState shared];
	[ConnectionHelper twitter_postTweetWithTarget:self action:@selector(doneSendingMessageToTwitter:) message:message username:state.twitterUsername password:state.twitterPassword];
}

- (void)sendMessageToFacebook:(NSString *)message
{
	// TODO DAVEPECK
	sendingToFacebook = NO;
	[self doneSendingMessage];
}

- (void)sendMessage
{
	// Action!
	[self.activityIndicator startAnimating];
	
	// get and store the message
	WhereBeUsState *state = [WhereBeUsState shared];
	state.lastMessage = [self.messageText text];
	[state save];
	
	// do appropriate posts
	sendingToFacebook = state.hasFacebookCredentials;
	sendingToTwitter = state.hasTwitterCredentials;
	
	if (sendingToFacebook)
	{
		[self sendMessageToFacebook:state.lastMessage];
	}
	
	if (sendingToTwitter)
	{
		[self sendMessageToTwitter:state.lastMessage];
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
