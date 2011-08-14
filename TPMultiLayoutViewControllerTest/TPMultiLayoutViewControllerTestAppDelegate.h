//
//  TPMultiLayoutViewControllerTestAppDelegate.h
//  TPMultiLayoutViewControllerTest
//
//  Created by Michael Tyson on 14/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPMultiLayoutViewControllerTestViewController;

@interface TPMultiLayoutViewControllerTestAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TPMultiLayoutViewControllerTestViewController *viewController;

@end
