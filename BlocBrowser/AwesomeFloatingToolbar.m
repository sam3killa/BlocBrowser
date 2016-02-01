//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Samuel Shih on 1/29/16.
//  Copyright © 2016 Samuel Shih. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

// Creating properties to store the labels, colors, and titles
@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;

// Property to keep track of which label the user is currently touching
@property (nonatomic, weak) UILabel *currentLabel;

// Tap Gesture Recognizer
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation AwesomeFloatingToolbar


- (instancetype)initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];

    if (self) {
        
        // Save the titles and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];

        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            
            // Create a new label
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            // Set up properties of the label
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; //Index 0-3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            // Program the labels
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            // Add the label to the labelsArray
            [labelsArray addObject:label];
        
        }
        
        // Add the labelsArray to the labels property
        self.labels = labelsArray;
        
        // Add the labels to the view
        for (UILabel *thisLabel in self.labels){
            [self addSubview:thisLabel];
        }
        
        // Initialize the tap gesture to call the tapFired method
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        // Add the gesture recognizer tap gesture
        [self addGestureRecognizer:self.tapGesture];
        
        // Pan Gesture recognizer
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
    }
    
    return self;

}

// Tap Fired Method

- (void) tapFired:(UIGestureRecognizer *) recognizer {
    
    // Check for the proper state
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        // Calculates and stores where the touch was located. An x y coordinate
        CGPoint location = [recognizer locationInView:self];
        
        // Finds out which view received the tap
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        // Check to see if the view that was tapped was one of our toolbar labels
        if ([self.labels containsObject:tappedView]) { // #6
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
                
                NSLog(@"Tapped Label");
            }
        }
    }
}

// Pan Fired Method

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    
    // Recognize that the state has changed
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        // How far the finger has moved in each direction since the event began
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}


// Layout Subviews will be called any time a view's frame is changed
- (void)layoutSubviews {
    
    for (UILabel *thisLabel in self.labels){
        // Keep current index of the label
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        // Determine the label dimension floats
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // Adjust labelX and labelY for each label depending on which label is on the top or bottom
        
        // Set the Y for the labels
        if (currentLabelIndex <2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds)/2 ;
        }
        
        // Set the X for the labels
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }

    
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }


}

// A method to determine which label was touched by the user
- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *) event {
    
    // Takes a touch from the touch set
    UITouch *touch = [touches anyObject];
    
    // Finds the coordinates of the touch on the screen
    CGPoint location = [touch locationInView:self];
    
    // Finds the UIView at that location
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]){
        return (UILabel *)subview;
    } else {
        return nil;
    }
}


// Enabling the buttons to perform their operation
- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
    
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
    
}

// OLD TOUCH METHODS
//// When a touch begans run this code
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    // Gets the current label that was touched
//    UILabel *label = [self labelFromTouches:touches withEvent:event];
//
//    self.currentLabel = label;
//    self.currentLabel.alpha = 0.5;
//
//}
//
//// When the user moves their finger off the label the button doesn't dim anymore
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//    // Gets the current label that was touched
//    UILabel *label = [self labelFromTouches:touches withEvent:event];
//
//    if (self.currentLabel != label) {
//
//        // The label being toucehd is no longer the inital label reset the button to be opaque
//        self.currentLabel.alpha = 1;
//
//    } else {
//
//        // The label being touched is the initial label
//        self.currentLabel.alpha = 0.5;
//    }
//}
//
//// When a touch ends meaning the user lifts their finger up after touching the screen
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//    UILabel *label = [self labelFromTouches:touches withEvent:event];
//
//    if (self.currentLabel == label){
//
//        NSLog(@"Label tapped : %@",self.currentLabel.text);
//
//        // The finger was lifted from the same label the user started with then inform the delegate. Check to see if the delegate is implementing theoptional method
//        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)])  {
//
//            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
//
//        }
//
//    }
//    self.currentLabel.alpha = 1;
//    self.currentLabel = nil;
//
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
//    self.currentLabel.alpha = 1;
//    self.currentLabel = nil;
//}



@end
