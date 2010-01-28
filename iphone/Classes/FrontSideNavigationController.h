//
//  FrontSideNavigationController.h
//  WhereBeUs
//
//  Created by Dave Peck on 12/8/09.
//  Copyright 2009 Code Orange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateAnnotation.h"

@interface FrontSideNavigationController : UINavigationController {

}

- (void)showMapViewController:(BOOL)animated;
- (void)showModalSendMessage;
- (void)showModalSendMessageWithCustomMessage:(NSString *)customMessage;
- (void)hideModalSendMessage;
- (void)showUpdateDetailView:(UpdateAnnotation *)annotation animated:(BOOL)animated;

@end
