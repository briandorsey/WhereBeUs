//
//  TweetViewController.m
//  TweetSpot
//
//  Created by Dave Peck on 11/1/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetSpotState.h"
#import "Utilities.h"
#import "TweetSpotAppDelegate.h"
#import "ConnectionHelper.h"
#import "JsonResponse.h"


@implementation TweetViewController

@synthesize messageText;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle 
{
	self = [super initWithNibName:nibName bundle:nibBundle];
    if (self != nil) 
	{
		self.title = @"Send A Tweet!";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	TweetSpotState *state = [TweetSpotState shared];
	
	if (state.currentMessage != nil && [state.currentMessage length] > 0)
	{
		[self.messageText setText:state.currentMessage];
	}
	else if (state.currentHashtag != nil && [state.currentHashtag length] > 0)
	{
		[self.messageText setText:[NSString stringWithFormat:@"Follow me with Tweet The Spot: #%@. http://tweetthespot.com/TODO/", state.currentHashtag]];
	}
	else
	{
		NSAssert(NO, @"Should never get here.");
	}
	
	[self.messageText becomeFirstResponder];
	
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)dealloc 
{
	self.messageText = nil;
    [super dealloc];
}

- (void)postTweet
{
	// set the message
	TweetSpotState *state = [TweetSpotState shared];
	state.currentMessage = [self.messageText text];
	[state save];
	
	// send the message!
	[ConnectionHelper twitter_postTweetWithTarget:self action:@selector(twitter_donePostTweet:) message:state.currentMessage username:state.twitterUsername password:state.twitterPassword];
	
	// done; back to the map.
	[(TweetSpotAppDelegate *)[[UIApplication sharedApplication] delegate] popViewController:YES];
}

- (void)twitter_donePostTweet:(JsonResponse *)response
{
	if (response == nil)
	{
		[Utilities displayModalAlertWithTitle:@"Twitter Failure" message:@"Couldn't post your tweet. Please try again." buttonTitle:@"OK"];
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text 
{
	if ([text isEqualToString:@"\n"]) 
	{
		// The "send" button was pressed! -- yes, this is really how to do it with a UITextVIEW (not UITextField)
		[textView resignFirstResponder];
		[self postTweet];
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
