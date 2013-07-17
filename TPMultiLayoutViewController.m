//
//  TPMultiLayoutViewController.m
//
//  Created by Michael Tyson on 14/08/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "TPMultiLayoutViewController.h"

#define VERBOSE_MATCH_FAIL 1 // Comment this out to be less verbose when associated views can't be found

@interface TPMultiLayoutViewController ()
- (NSDictionary*)attributeTableForViewHierarchy:(UIView*)rootView associateWithViewHierarchy:(UIView*)associatedRootView;
- (void)addAttributesForSubviewHierarchy:(UIView*)view associatedWithSubviewHierarchy:(UIView*)associatedView toTable:(NSMutableDictionary*)table;
- (UIView*)findAssociatedViewForView:(UIView*)view amongViews:(NSArray*)views;
- (void)applyAttributeTable:(NSDictionary*)table toViewHierarchy:(UIView*)view duration:(NSTimeInterval)duration;
- (NSDictionary*)attributesForView:(UIView*)view;
- (void)applyAttributes:(NSDictionary*)attributes toView:(UIView*)view duration:(NSTimeInterval)duration;
- (BOOL)shouldDescendIntoSubviewsOfView:(UIView*)view;

@property (nonatomic, strong) NSDictionary *portraitAttributes;
@property (nonatomic, strong) NSDictionary *landscapeAttributes;
@property (nonatomic, assign) BOOL viewIsCurrentlyPortrait;

@end

static NSMutableSet* sViewClassesToIgnore = nil;

@implementation TPMultiLayoutViewController

#pragma mark - View lifecycle

+(void)registerViewClassToIgnore:(Class)viewClass
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sViewClassesToIgnore = [[NSMutableSet alloc] init];
	});
	
	[sViewClassesToIgnore addObject:viewClass];
}

+(void)initialize
{
	[self registerViewClassToIgnore:[UISlider class]];
	[self registerViewClassToIgnore:[UISwitch class]];
	[self registerViewClassToIgnore:[UITextField class]];
	[self registerViewClassToIgnore:[UIWebView class]];
	[self registerViewClassToIgnore:[UITableView class]];
	[self registerViewClassToIgnore:[UIPickerView class]];
	[self registerViewClassToIgnore:[UIDatePicker class]];
	[self registerViewClassToIgnore:[UITextView class]];
	[self registerViewClassToIgnore:[UIProgressView class]];
	[self registerViewClassToIgnore:[UISegmentedControl class]];

	[super initialize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Construct attribute tables
    self.portraitAttributes = [self attributeTableForViewHierarchy:self.portraitView associateWithViewHierarchy:self.view];
    self.landscapeAttributes = [self attributeTableForViewHierarchy:self.landscapeView associateWithViewHierarchy:self.view];
    self.viewIsCurrentlyPortrait = (self.view == self.portraitView);
}

-(void)viewWillAppear:(BOOL)animated {
    // Display correct layout for orientation
    if ( (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && !self.viewIsCurrentlyPortrait) ||
         (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.viewIsCurrentlyPortrait) ) {
        [self applyLayoutForInterfaceOrientation:self.interfaceOrientation duration:0];
    }
}

#pragma mark - Rotation

- (void)applyLayoutForInterfaceOrientation:(UIInterfaceOrientation)newOrientation duration:(NSTimeInterval)duration {
    NSDictionary *table = UIInterfaceOrientationIsPortrait(newOrientation) ? self.portraitAttributes : self.landscapeAttributes;
    [self applyAttributeTable:table toViewHierarchy:self.view duration:duration];
    self.viewIsCurrentlyPortrait = UIInterfaceOrientationIsPortrait(newOrientation);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ( (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && !self.viewIsCurrentlyPortrait) ||
         (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && self.viewIsCurrentlyPortrait) ) {
        [self applyLayoutForInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

#pragma mark - Helpers

- (NSDictionary*)attributeTableForViewHierarchy:(UIView*)rootView associateWithViewHierarchy:(UIView*)associatedRootView {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    [self addAttributesForSubviewHierarchy:rootView associatedWithSubviewHierarchy:associatedRootView toTable:table];        
    return table;
}

- (void)addAttributesForSubviewHierarchy:(UIView*)view associatedWithSubviewHierarchy:(UIView*)associatedView toTable:(NSMutableDictionary*)table {
	// Ignore views with negative tag
	if ( view.tag < 0 ) {
		return;
	}

    [table setObject:[self attributesForView:view] forKey:[NSValue valueWithPointer:(__bridge const void *)(associatedView)]];
    
    if ( ![self shouldDescendIntoSubviewsOfView:view] ) return;
    
    for ( UIView *subview in view.subviews ) {
        UIView *associatedSubView = (view == associatedView ? subview : [self findAssociatedViewForView:subview amongViews:associatedView.subviews]);
        if ( associatedSubView ) {
            [self addAttributesForSubviewHierarchy:subview associatedWithSubviewHierarchy:associatedSubView toTable:table];
        }
    }
}

- (UIView*)findAssociatedViewForView:(UIView*)view amongViews:(NSArray*)views {
	// First try to match tag
    if ( view.tag != 0 ) {
        UIView *associatedView = [[views filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"tag = %d", view.tag]] lastObject];
        if ( associatedView ) return associatedView;
    }
    
    // Next, try to match class, targets and actions, if it's a control
    if ( [view isKindOfClass:[UIControl class]] && [[(UIControl*)view allTargets] count] > 0 ) {
        for ( UIView *otherView in views ) {
            if ( [otherView isKindOfClass:[view class]]
                    && [[(UIControl*)otherView allTargets] isEqualToSet:[(UIControl*)view allTargets]] 
                    && [(UIControl*)otherView allControlEvents] == [(UIControl*)view allControlEvents] ) {
                // Try to match all actions and targets for each associated control event
                BOOL allActionsMatch = YES;
                UIControlEvents controlEvents = [(UIControl*)otherView allControlEvents];
                for ( id target in [(UIControl*)otherView allTargets] ) {
                    // Iterate over each bit in the UIControlEvents bitfield
                    for ( NSInteger i=0; i<(NSInteger)sizeof(UIControlEvents)*8; i++ ) {
                        UIControlEvents event = 1 << i;
                        if ( !(controlEvents & event) ) continue;
                        if ( ![[(UIControl*)otherView actionsForTarget:target forControlEvent:event] isEqualToArray:[(UIControl*)view actionsForTarget:target forControlEvent:event]] ) {
                            allActionsMatch = NO;
                            break;
                        }
                    }
                    if ( !allActionsMatch ) break;
                }
                
                if ( allActionsMatch ) {
                    return otherView;
                }
            }
        }
    }
    
    // Next, try to match title or image, if it's a button
    if ( [view isKindOfClass:[UIButton class]] ) {
        for ( UIView *otherView in views ) {
            if ( [otherView isKindOfClass:[view class]] && [[(UIButton*)otherView titleForState:UIControlStateNormal] isEqualToString:[(UIButton*)view titleForState:UIControlStateNormal]] ) {
                return otherView;
            }
        }

        for ( UIView *otherView in views ) {
            if ( [otherView isKindOfClass:[view class]] && [(UIButton*)otherView imageForState:UIControlStateNormal] == [(UIButton*)view imageForState:UIControlStateNormal] ) {
                return otherView;
            }
        }
    }
    
    // Try to match by title if it's a label
    if ( [view isKindOfClass:[UILabel class]] ) {
        for ( UIView *otherView in views ) {
            if ( [otherView isKindOfClass:[view class]] && [[(UILabel*)otherView text] isEqualToString:[(UILabel*)view text]] ) {
                return otherView;
            }
        }
    }
    
    // Try to match by text/placeholder if it's a text field
    if ( [view isKindOfClass:[UITextField class]] ) {
        for ( UIView *otherView in views ) {
            if ( [otherView isKindOfClass:[view class]] && ([(UITextField*)view text] || [(UITextField*)view placeholder]) &&
                    ((![(UITextField*)view text] && ![(UITextField*)otherView text]) || [[(UITextField*)otherView text] isEqualToString:[(UITextField*)view text]]) &&
                    ((![(UITextField*)view placeholder] && ![(UITextField*)otherView placeholder]) || [[(UITextField*)otherView placeholder] isEqualToString:[(UITextField*)view placeholder]]) ) {                
                return otherView;
            }
        }
    }
    
    // Finally, try to match by class
    NSArray *matches = [views filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", [view class]]];
    if ( [matches count] == 1 ) return [matches lastObject];
    
#if VERBOSE_MATCH_FAIL
    NSMutableString *path = [NSMutableString string];
    for ( UIView *v = view.superview; v != nil; v = v.superview ) {
        [path insertString:[NSString stringWithFormat:@"%@ => ", NSStringFromClass([v class])] atIndex:0];
    }
    NSLog(@"Couldn't find match for %@%@", path, NSStringFromClass([view class]));
    
#endif
    
    return nil;
}

- (void)applyAttributeTable:(NSDictionary*)table toViewHierarchy:(UIView*)view duration:(NSTimeInterval)duration {
    NSDictionary *attributes = [table objectForKey:[NSValue valueWithPointer:(__bridge const void *)(view)]];
    if ( attributes ) {
        [self applyAttributes:attributes toView:view duration:duration];
    }
    
    if ( view.hidden ) return;
    
    if ( ![self shouldDescendIntoSubviewsOfView:view] ) return;
    
    for ( UIView *subview in view.subviews ) {
        [self applyAttributeTable:table toViewHierarchy:subview duration:duration];
    }
}

- (NSDictionary*)attributesForView:(UIView*)view {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
    [attributes setObject:[NSValue valueWithCGRect:view.bounds] forKey:@"bounds"];
    [attributes setObject:[NSNumber numberWithBool:view.hidden] forKey:@"hidden"];
    [attributes setObject:[NSNumber numberWithInteger:view.autoresizingMask] forKey:@"autoresizingMask"];
    
    return attributes;
}

- (void)applyAttributes:(NSDictionary*)attributes toView:(UIView*)view duration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration
					 animations:^{
						 view.frame = [[attributes objectForKey:@"frame"] CGRectValue];
						 view.bounds = [[attributes objectForKey:@"bounds"] CGRectValue];
						 view.hidden = [[attributes objectForKey:@"hidden"] boolValue];
						 view.autoresizingMask = [[attributes objectForKey:@"autoresizingMask"] integerValue];
					 }];
}

- (BOOL)shouldDescendIntoSubviewsOfView:(UIView*)view {
    if ([sViewClassesToIgnore containsObject:[view class]]) return NO;
    return YES;
}

@end
