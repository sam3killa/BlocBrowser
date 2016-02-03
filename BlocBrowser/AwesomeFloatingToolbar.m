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

// Property to keep track of which label the user is currently touching
@property (nonatomic, weak) UIButton *currentButton;

// Tap Gesture Recognizer
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

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

        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            
            // Create a new label
            UIButton *button = [[UIButton alloc] init];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            // Set up properties of the label
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; //Index 0-3
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisButton = [self.colors objectAtIndex:currentTitleIndex];
            
            // Program the labels
            button.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            [button setBackgroundColor:colorForThisButton];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [button addTarget:self action:@selector(tapFired:) forControlEvents:UIControlEventTouchUpInside];
            
            // Add the button to the buttonsArray
            [buttonsArray addObject:button];
        
        }
        
        // Add the labelsArray to the labels property
        self.buttons = buttonsArray;
        
        // Add the labels to the view
        for (UIButton *thisButton in self.buttons){
            [self addSubview:thisButton];
        }
        
        // Adding the Gesture Recognizers to the view controller
        
//        // Initialize the tap gesture to call the tapFired method
//        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
//        // Add the gesture recognizer tap gesture
//        [self addGestureRecognizer:self.tapGesture];
        
        
        // Pan Gesture recognizer
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        // Pinch Gesture recognizer
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        // Long Press Gesture recognizer
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
    }
    
    return self;

}

// Tap Fired Method

- (void) tapFired:(UIButton *) button {
    
    NSLog(@"Button Fired");
    
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:[button currentTitle]];
                
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

// Pinch Fired Method

- (void) pinchFired:(UIPinchGestureRecognizer *) recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGFloat scale = [recognizer scale];
        NSLog(@"%f",scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didPinchToolbar:)]){

            [self.delegate floatingToolbar:self didPinchToolbar: scale];
              
        }
        
    }
}

// Long Press Method

- (void) longPressFired:(UILongPressGestureRecognizer *) recognizer {

    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        NSLog(@"Long Press Registered");
        
        CFTimeInterval timeInterval = [recognizer minimumPressDuration];
        
        if([self.delegate respondsToSelector:@selector(floatingToolbar:didLongPress:)]) {
            self.colors = @[self.colors[1], self.colors[2], self.colors[3], self.colors[0]];
            NSLog(@"%@",self.colors);
            // You want to rotate the colors in the array.
            [self.delegate floatingToolbar:self didLongPress:timeInterval];

        }
        
    }

}

// Layout Subviews will be called any time a view's frame is changed
- (void)layoutSubviews {
    
    for (UILabel *thisLabel in self.buttons){
        // Keep current index of the label
        NSUInteger currentLabelIndex = [self.buttons indexOfObject:thisLabel];
        
        // Determine the label dimension floats
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // Adjust labelX and labelY for each label depending on which label is on the top or bottom
        
        // Set the Y for the labels
        if (currentLabelIndex < 2) {
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
    
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
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
