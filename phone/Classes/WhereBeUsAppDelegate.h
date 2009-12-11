//
//  WhereBeUsAppDelegate.h
//  WhereBeUs
//
//  Created by Dave Peck on 10/27/09.
//  Copyright Code Orange 2009. All rights reserved.
//

#import "WhereBeUsWindow.h"
#import "FrontSideNavigationController.h"
#import "BackSideNavigationController.h"
#import "FBConnect/FBConnect.h"

@interface WhereBeUsAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate> {    
    IBOutlet WhereBeUsWindow *window;
    IBOutlet FrontSideNavigationController *frontSideNavigationController;
    IBOutlet BackSideNavigationController *backSideNavigationController; // effectively, a modal view controller to the frontSideNavController.
	BOOL showingFrontSide;
}

@property (nonatomic, retain) IBOutlet WhereBeUsWindow *window;
@property (nonatomic, retain) IBOutlet FrontSideNavigationController *frontSideNavigationController;
@property (nonatomic, retain) IBOutlet BackSideNavigationController *backSideNavigationController;

- (BOOL)showingFrontSide;
- (BOOL)showingBackSide;
- (void)flip:(BOOL)animated;

@end




