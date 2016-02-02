//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Samuel Shih on 1/29/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

// Defining my AwesomeFloatingToolbar class
@class AwesomeFloatingToolbar;

// Promises compiler that we will define what the Awesome Floating Toolbar is later. It conforms to the NSObject protocol.
@protocol AwesomeFloatingToolbarDelegate <NSObject>

// Define Optional delegate methods
@optional

// If the delegate implements it, it will be called when a user taps a button.
- (void) floatingToolbar: (AwesomeFloatingToolbar *) toolbar didSelectButtonWithTitle:(NSString *)title;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didPinchToolbar:(CGFloat)scale;
- (void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didLongPress:(CFTimeInterval) minimumPressDuration;

@end

// Interface of the toolbar itself
@interface AwesomeFloatingToolbar : UIView

// A custom initializer to use, which takes an array of four titles as an argument
- (instancetype) initWithFourTitles:(NSArray *)titles;

@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *colors;


// A method that set's whether a button is enabled based on the title
- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

// A delegate property to use if a delegate is wanted by a user
@property (nonatomic, weak) id <AwesomeFloatingToolbarDelegate> delegate;


@end
