//
//  TPMultiLayoutViewControllerTestViewController.h
//  TPMultiLayoutViewControllerTest
//
//  Created by Michael Tyson on 14/08/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPMultiLayoutViewController.h"

@interface TPMultiLayoutViewControllerTestViewController : TPMultiLayoutViewController {
    UILabel *sliderLabel;
}

- (IBAction)updateSliderLabel:(id)sender;

@property (nonatomic, retain) IBOutlet UILabel *sliderLabel;
@end
