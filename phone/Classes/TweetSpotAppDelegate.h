//
//  TweetSpotAppDelegate.h
//  TweetSpot
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "TweetSpotWindow.h"

@interface TweetSpotAppDelegate : NSObject <UIApplicationDelegate> {
    
    TweetSpotWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet TweetSpotWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

