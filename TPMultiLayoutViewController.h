//
//  TPMultiLayoutViewController.h
//
//  Created by Michael Tyson on 14/08/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPMultiLayoutViewController : UIViewController

// Call directly to use with custom animation (override willRotateToInterfaceOrientation to disable the switch there)
- (void)applyLayoutForInterfaceOrientation:(UIInterfaceOrientation)newOrientation duration:(NSTimeInterval)duration;

// Call this with the class of custom views you do not wish TPMultiLayoutViewController to descend into.
+(void)registerViewClassToIgnore:(Class)viewClass;

@property (nonatomic, retain) IBOutlet UIView *landscapeView;
@property (nonatomic, retain) IBOutlet UIView *portraitView;
@end
