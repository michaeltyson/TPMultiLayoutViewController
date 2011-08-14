//
//  TPMultiLayoutViewControllerTestViewController.m
//  TPMultiLayoutViewControllerTest
//
//  Created by Michael Tyson on 14/08/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "TPMultiLayoutViewControllerTestViewController.h"

@implementation TPMultiLayoutViewControllerTestViewController
@synthesize sliderLabel;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setSliderLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc {
    [sliderLabel release];
    [super dealloc];
}

- (IBAction)updateSliderLabel:(id)sender {
    sliderLabel.text = [NSString stringWithFormat:@"%g", ((UISlider*)sender).value];
}

@end
